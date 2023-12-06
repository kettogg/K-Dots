/*
 * Copyright 2014  Martin Gräßlin <mgraesslin@kde.org>
 * Copyright 2014  Hugo Pereira Da Costa <hugo.pereira@free.fr>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "breezebutton.h"

#include <KColorUtils>
#include <KDecoration2/DecoratedClient>
#include <KIconLoader>
#include <QPainter>
#include <QPainterPath>

namespace Breeze {

using KDecoration2::ColorGroup;
using KDecoration2::ColorRole;
using KDecoration2::DecorationButtonType;

//__________________________________________________________________
Button::Button(DecorationButtonType type, Decoration *decoration, QObject *parent)
    : DecorationButton(type, decoration, parent), m_animation(new QVariantAnimation(this)) {
    // setup animation
    // It is important start and end value are of the same type, hence 0.0 and not just 0
    m_animation->setStartValue(0.0);
    m_animation->setEndValue(1.0);
    // Linear to have the same easing as Breeze animations
    m_animation->setEasingCurve(QEasingCurve::Linear);
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) { setOpacity(value.toReal()); });

    // setup default geometry
    const int height = decoration->buttonHeight();
    setGeometry(QRect(0, 0, height, height));
    setIconSize(QSize(height, height));

    // connections
    connect(decoration->client().toStrongRef().data(), SIGNAL(iconChanged(QIcon)), this, SLOT(update()));
    connect(decoration->settings().data(), &KDecoration2::DecorationSettings::reconfigured, this, &Button::reconfigure);
    connect(this, &KDecoration2::DecorationButton::hoveredChanged, this, &Button::updateAnimationState);

    if (decoration->objectName() == "applet-window-buttons") {
        connect(this, &Button::hoveredChanged, [=](bool hovered) { decoration->setButtonHovered(hovered); });
    }
    connect(decoration, SIGNAL(buttonHoveredChanged()), this, SLOT(update()));

    reconfigure();
}

//__________________________________________________________________
Button::Button(QObject *parent, const QVariantList &args)
    : Button(args.at(0).value<DecorationButtonType>(), args.at(1).value<Decoration *>(), parent) {
    m_flag = FlagStandalone;
    //! icon size must return to !valid because it was altered from the default constructor,
    //! in Standalone mode the button is not using the decoration metrics but its geometry
    m_iconSize = QSize(-1, -1);
}

//__________________________________________________________________
Button *Button::create(DecorationButtonType type, KDecoration2::Decoration *decoration, QObject *parent) {
    if (auto d = qobject_cast<Decoration *>(decoration)) {
        Button *b = new Button(type, d, parent);
        switch (type) {
            case DecorationButtonType::Close:
                b->setVisible(d->client().toStrongRef().data()->isCloseable());
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::closeableChanged, b, &Breeze::Button::setVisible);
                break;

            case DecorationButtonType::Maximize:
                b->setVisible(d->client().toStrongRef().data()->isMaximizeable());
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::maximizeableChanged, b,
                                 &Breeze::Button::setVisible);
                break;

            case DecorationButtonType::Minimize:
                b->setVisible(d->client().toStrongRef().data()->isMinimizeable());
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::minimizeableChanged, b,
                                 &Breeze::Button::setVisible);
                break;

            case DecorationButtonType::ContextHelp:
                b->setVisible(d->client().toStrongRef().data()->providesContextHelp());
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::providesContextHelpChanged, b,
                                 &Breeze::Button::setVisible);
                break;

            case DecorationButtonType::Shade:
                b->setVisible(d->client().toStrongRef().data()->isShadeable());
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::shadeableChanged, b, &Breeze::Button::setVisible);
                break;

            case DecorationButtonType::Menu:
                QObject::connect(d->client().toStrongRef().data(), &KDecoration2::DecoratedClient::iconChanged, b, [b]() { b->update(); });
                break;

            default:
                break;
        }

        return b;
    }

    return nullptr;
}

//__________________________________________________________________
void Button::paint(QPainter *painter, const QRect &repaintRegion) {
    Q_UNUSED(repaintRegion)

    if (!decoration()) return;

    painter->save();

    // translate from offset
    if (m_flag == FlagFirstInList)
        painter->translate(m_offset);
    else
        painter->translate(0, m_offset.y());

    if (!m_iconSize.isValid()) m_iconSize = geometry().size().toSize();

    // menu button
    if (type() == DecorationButtonType::Menu) {
        const QRectF iconRect(geometry().topLeft(), 0.8 * m_iconSize);
        const qreal width(m_iconSize.width());
        painter->translate(0.1 * width, 0.1 * width);
        if (auto deco = qobject_cast<Decoration *>(decoration())) {
            const QPalette activePalette = KIconLoader::global()->customPalette();
            QPalette palette = decoration()->client().toStrongRef().data()->palette();
            palette.setColor(QPalette::Foreground, deco->fontColor());
            KIconLoader::global()->setCustomPalette(palette);
            decoration()->client().toStrongRef().data()->icon().paint(painter, iconRect.toRect());
            if (activePalette == QPalette()) {
                KIconLoader::global()->resetPalette();
            } else {
                KIconLoader::global()->setCustomPalette(palette);
            }
        } else {
            decoration()->client().toStrongRef().data()->icon().paint(painter, iconRect.toRect());
        }

    } else {
        auto d = qobject_cast<Decoration *>(decoration());

        if (d && d->internalSettings()->buttonStyle() == 0)
            drawIconPlasma(painter);
        else
            drawMauiStyle(painter);
    }

    painter->restore();
}

//__________________________________________________________________
void Button::drawIconPlasma(QPainter *painter) const {
    painter->setRenderHints(QPainter::Antialiasing);

    /*
        scale painter so that its window matches QRect( -1, -1, 20, 20 )
        this makes all further rendering and scaling simpler
        all further rendering is preformed inside QRect( 0, 0, 18, 18 )
        */
    painter->translate(geometry().topLeft());

    const qreal width(m_iconSize.width());
    painter->scale(width / 20, width / 20);
    painter->translate(1, 1);

    // render background
    QColor backgroundColor(this->backgroundColor());
    if (backgroundColor.isValid()) {
        painter->setPen(Qt::NoPen);
        painter->setBrush(backgroundColor);
        painter->drawEllipse(QRectF(0, 0, 18, 18));
    }

    // render mark
    QColor foregroundColor(this->foregroundColor());
    if (foregroundColor.isValid()) {
        // setup painter
        QPen pen(foregroundColor);
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::MiterJoin);
        pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));

        painter->setPen(pen);
        painter->setBrush(Qt::NoBrush);

        switch (type()) {
            case DecorationButtonType::Close: {
                painter->drawLine(QPointF(5, 5), QPointF(13, 13));
                painter->drawLine(13, 5, 5, 13);
                break;
            }

            case DecorationButtonType::Maximize: {
                if (isChecked()) {
                    pen.setJoinStyle(Qt::RoundJoin);
                    painter->setPen(pen);

                    painter->drawPolygon(QVector<QPointF>{QPointF(4, 9), QPointF(9, 4), QPointF(14, 9), QPointF(9, 14)});

                } else {
                    painter->drawPolyline(QVector<QPointF>{QPointF(4, 11), QPointF(9, 6), QPointF(14, 11)});
                }
                break;
            }

            case DecorationButtonType::Minimize: {
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 7), QPointF(9, 12), QPointF(14, 7)});
                break;
            }

            case DecorationButtonType::OnAllDesktops: {
                painter->setPen(Qt::NoPen);
                painter->setBrush(foregroundColor);

                if (isChecked()) {
                    // outer ring
                    painter->drawEllipse(QRectF(3, 3, 12, 12));

                    // center dot
                    QColor backgroundColor(this->backgroundColor());
                    auto d = qobject_cast<Decoration *>(decoration());
                    if (!backgroundColor.isValid() && d) backgroundColor = d->titleBarColor();

                    if (backgroundColor.isValid()) {
                        painter->setBrush(backgroundColor);
                        painter->drawEllipse(QRectF(8, 8, 2, 2));
                    }

                } else {
                    painter->drawPolygon(QVector<QPointF>{QPointF(6.5, 8.5), QPointF(12, 3), QPointF(15, 6), QPointF(9.5, 11.5)});

                    painter->setPen(pen);
                    painter->drawLine(QPointF(5.5, 7.5), QPointF(10.5, 12.5));
                    painter->drawLine(QPointF(12, 6), QPointF(4.5, 13.5));
                }
                break;
            }

            case DecorationButtonType::Shade: {
                if (isChecked()) {
                    painter->drawLine(QPointF(4, 5.5), QPointF(14, 5.5));  // painter->drawLine( 4, 5, 14, 5 );
                    painter->drawPolyline(QVector<QPointF>{QPointF(4, 8), QPointF(9, 13), QPointF(14, 8)});

                } else {
                    painter->drawLine(QPointF(4, 5.5), QPointF(14, 5.5));  // painter->drawLine( 4, 5, 14, 5 );
                    painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
                }

                break;
            }

            case DecorationButtonType::KeepBelow: {
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 5), QPointF(9, 10), QPointF(14, 5)});

                painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 14), QPointF(14, 9)});
                break;
            }

            case DecorationButtonType::KeepAbove: {
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 4), QPointF(14, 9)});

                painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
                break;
            }

            case DecorationButtonType::ApplicationMenu: {
                painter->drawRect(QRectF(3.5, 4.5, 11, 1));   // painter->drawLine( QPointF( 3.5, 5 ), QPointF( 14.5, 5 ) );
                painter->drawRect(QRectF(3.5, 8.5, 11, 1));   // painter->drawLine( QPointF( 3.5, 9 ), QPointF( 14.5, 9 ) );
                painter->drawRect(QRectF(3.5, 12.5, 11, 1));  // painter->drawLine( QPointF( 3.5, 13 ), QPointF( 14.5, 13 ) );
                break;
            }

            case DecorationButtonType::ContextHelp: {
                QPainterPath path;
                path.moveTo(5, 6);
                path.arcTo(QRectF(5, 3.5, 8, 5), 180, -180);
                path.cubicTo(QPointF(12.5, 9.5), QPointF(9, 7.5), QPointF(9, 11.5));
                painter->drawPath(path);

                painter->drawRect(QRectF(9, 15, 0.5, 0.5));  // painter->drawPoint( 9, 15 );

                break;
            }

            default:
                break;
        }
    }
}

//__________________________________________________________________
void Button::drawMauiStyle(QPainter *painter) const {
    painter->setRenderHints(QPainter::Antialiasing);

    /*
        scale painter so that its window matches QRect( -1, -1, 20, 20 )
        this makes all further rendering and scaling simpler
        all further rendering is preformed inside QRect( 0, 0, 18, 18 )
        */
    painter->translate(geometry().topLeft());

    const qreal width(m_iconSize.width());
    auto d = qobject_cast<Decoration *>(decoration());

    painter->scale(width / 20, width / 20);
    painter->translate(1, 1);

    QColor titleBarColor(d->titleBarColor());
    bool inactiveWindow(d && !d->client().toStrongRef().data()->isActive());
    bool isDarkTheme(qGray(titleBarColor.rgb()) < 128);

    const QColor backgroundColor = d->titleBarColor();
    const QColor foregroundColor = d->fontColor();

    const auto getPen = [=](const QColor &color) -> QPen {
        QPen pen(color);
        pen.setJoinStyle(Qt::RoundJoin);
        pen.setWidthF(1.7 * qMax((qreal)1.0, 20 / width));
        return pen;
    };

    const auto backgroundStateColor = [&](const QColor &baseColor) -> QColor {
        if (inactiveWindow) {
            if (isPressed())
                return QColor("lightgray");
            else if (!isPressed())
                return QColor("transparent");
        }
        if (isHovered())
            return QColor("transparent");
        else
            return baseColor;
    };

    const auto iconStateColor = [&](const QColor &baseColor, const bool &isDark) -> QColor {
        if (inactiveWindow) {
            if (isDark) {
                if (!isHovered() && !isPressed()) {
                    return foregroundColor.darker(150);

                } else if (isHovered() && !isPressed()) {
                    return foregroundColor.lighter(150);
                } else {
                    return QColor("white");
                }
            } else {
                if (!isHovered() && !isPressed()) {
                    return foregroundColor.lighter(150);

                } else if (isHovered() && !isPressed()) {
                    return foregroundColor.darker(150);
                } else {
                    return QColor("black");
                }
            }
        } else {
            if (isHovered()) {
                return baseColor;
            } else {
                return QColor("white");
            }
        }
    };

    const auto borderStateColor = [&](const QColor &baseColor, const bool &isDark) -> QColor {
        if (inactiveWindow) {
            if (isDark) {
                if (!isHovered() && !isPressed()) {
                    return foregroundColor.darker();
                } else if (isHovered() && !isPressed()) {
                    return foregroundColor.darker(150);
                } else {
                    return QColor("gray");
                }
            } else {
                if (!isHovered() && !isPressed()) {
                    return foregroundColor.lighter(150);
                } else if (isHovered() && !isPressed()) {
                    return foregroundColor.darker(150);
                } else {
                    return QColor("gray");
                }
            }

        } else {
            if (isPressed()) {
                return baseColor.darker(150);
            } else {
                return baseColor.darker(130);
            }
        }
    };

    qreal r = this->buttonRadius();
    QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
    QPen pen;
    pen.setJoinStyle(Qt::RoundJoin);

    switch (type()) {
        case DecorationButtonType::Close: {
            QColor closeColor = "#f06292";
            painter->setBrush(backgroundStateColor(closeColor));

            if (isHovered()) {
                if (isDarkTheme)
                    pen.setColor(borderStateColor(closeColor, isDarkTheme).darker(180));
                else
                    pen.setColor(borderStateColor(closeColor, isDarkTheme).lighter(180));

                painter->setPen(pen);
                painter->drawEllipse(c, r + 1, r + 1);
            }
            pen.setColor(borderStateColor(closeColor, isDarkTheme));
            painter->setPen(pen);
            painter->setBrush(backgroundStateColor(closeColor));
            painter->drawEllipse(c, r, r);

            pen.setColor(iconStateColor(closeColor, isDarkTheme));

            if (d->internalSettings()->animationsEnabled()) {
                pen.setWidthF(1.7 * qMax((qreal)1.0, 20 / width));
                painter->setPen(pen);
                painter->drawLine(QPointF(6, 6), QPointF(12, 12));
                painter->drawLine(QPointF(6, 12), QPointF(12, 6));
            } else {
                pen.setWidthF(2.5 * qMax((qreal)1.0, 20 / width));
                painter->setPen(pen);
                painter->drawLine(QPointF(6, 6), QPointF(12, 12));
                painter->drawLine(QPointF(6, 12), QPointF(12, 6));
            }

            break;
        }

        case DecorationButtonType::Maximize: {
            if (!d->client().data()->isMaximized()) {
                QColor maximizeColor = "#42a5f5";
                painter->setBrush(backgroundStateColor(maximizeColor));

                if (isHovered()) {
                    if (isDarkTheme)
                        pen.setColor(borderStateColor(maximizeColor, isDarkTheme).darker(180));
                    else
                        pen.setColor(borderStateColor(maximizeColor, isDarkTheme).lighter(120));

                    painter->setPen(pen);
                    painter->drawEllipse(c, r + 1, r + 1);
                }
                pen.setColor(borderStateColor(maximizeColor, isDarkTheme));
                painter->setPen(pen);
                painter->setBrush(backgroundStateColor(maximizeColor));
                painter->drawEllipse(c, r, r);

                pen.setColor(iconStateColor(maximizeColor, isDarkTheme));
                painter->setPen(pen);
                painter->setBrush(iconStateColor(maximizeColor, isDarkTheme));
                painter->drawPolygon(
                    QVector<QPointF>{QPointF(8, 6), QPointF(10, 6), QPointF(13, 10), QPointF(13, 11), QPointF(5, 11), QPointF(5, 10), QPointF(8, 6)});

            } else {
                QColor restoreColor = "#9575cd";
                QColor restorBorderColor = "#7e57c2";
                painter->setBrush(backgroundStateColor(restoreColor));
                if (isHovered()) {
                    if (isDarkTheme)
                        pen.setColor(borderStateColor(restoreColor, isDarkTheme).darker(180));
                    else
                        pen.setColor(borderStateColor(restoreColor, isDarkTheme).lighter(180));

                    painter->setPen(pen);
                    painter->drawEllipse(c, r + 1, r + 1);
                }
                pen.setColor(borderStateColor(restoreColor, isDarkTheme));
                painter->setPen(pen);
                painter->setBrush(backgroundStateColor(restoreColor));
                painter->drawEllipse(c, r, r);

                QPainterPath path;
                path.moveTo(9, 5);
                path.lineTo(13, 9);
                path.lineTo(9, 13);
                path.lineTo(5, 9);
                path.lineTo(9, 5);
                auto border = getPen(iconStateColor(restorBorderColor, isDarkTheme));
                border.setWidth(1);
                painter->strokePath(path, border);
                painter->fillPath(path, iconStateColor(restoreColor, isDarkTheme));
            }

            break;
        }

        case DecorationButtonType::Minimize: {
            QColor minimizeColor = "#4dd0e1";
            painter->setBrush(backgroundStateColor(minimizeColor));

            if (isHovered()) {
                if (isDarkTheme)
                    pen.setColor(borderStateColor(minimizeColor, isDarkTheme).darker(180));
                else
                    pen.setColor(borderStateColor(minimizeColor, isDarkTheme).lighter(180));

                painter->setPen(pen);
                painter->drawEllipse(c, r + 1, r + 1);
            }
            pen.setColor(borderStateColor(minimizeColor, isDarkTheme));
            painter->setPen(pen);
            painter->setBrush(backgroundStateColor(minimizeColor));
            painter->drawEllipse(c, r, r);

            painter->setBrush(iconStateColor(minimizeColor, isDarkTheme));
            pen.setColor(iconStateColor(minimizeColor, isDarkTheme));
            painter->setPen(pen);
            painter->drawPolygon(
                QVector<QPointF>{QPointF(5, 7), QPointF(13, 7), QPointF(13, 8), QPointF(10, 12), QPointF(8, 12), QPointF(5, 8), QPointF(5, 7)});

            break;
        }

        case DecorationButtonType::OnAllDesktops: {
            painter->setPen(Qt::NoPen);
            painter->setBrush(foregroundColor);

            if (isChecked()) {
                painter->drawEllipse(c, 9.0, 9.0);
                painter->setBrush(backgroundColor);
                painter->drawEllipse(c, 2.0, 2.0);
            } else
                painter->drawEllipse(c, 4.0, 4.0);
            break;
        }

        case DecorationButtonType::Shade: {
            break;
        }

        case DecorationButtonType::KeepBelow: {
            break;
        }

        case DecorationButtonType::KeepAbove: {
            break;
        }

        case DecorationButtonType::ApplicationMenu: {
            break;
        }

        case DecorationButtonType::ContextHelp: {
            break;
        }
        default:
            break;
    }
}

//__________________________________________________________________
//__________________________________________________________________
// https://stackoverflow.com/questions/25514812/how-to-animate-color-of-qbrush
QColor Button::mixColors(const QColor &cstart, const QColor &cend, qreal progress) const {
    int sh = cstart.hsvHue();
    int eh = cend.hsvHue();
    int ss = cstart.hsvSaturation();
    int es = cend.hsvSaturation();
    int sv = cstart.value();
    int ev = cend.value();
    int hr = qAbs(sh - eh);
    int sr = qAbs(ss - es);
    int vr = qAbs(sv - ev);
    int dirh = sh > eh ? -1 : 1;
    int dirs = ss > es ? -1 : 1;
    int dirv = sv > ev ? -1 : 1;

    return QColor::fromHsv(sh + dirh * progress * hr, ss + dirs * progress * sr, sv + dirv * progress * vr);
}

//__________________________________________________________________
QColor Button::foregroundColor() const {
    auto d = qobject_cast<Decoration *>(decoration());
    QColor titleBarColor(d->titleBarColor());

    if (!d) {
        return QColor();

    } else if (isPressed()) {
        return titleBarColor;

    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade) &&
               isChecked()) {
        return titleBarColor;

    } else if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(d->fontColor(), titleBarColor, m_opacity);

    } else if (this->hovered()) {
        return titleBarColor;

    } else {
        return d->fontColor();
    }
}

//__________________________________________________________________
QColor Button::backgroundColor() const {
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();
    }

    auto c = d->client().toStrongRef().data();
    if (isPressed()) {
        if (type() == DecorationButtonType::Close)
            return c->color(ColorGroup::Warning, ColorRole::Foreground);
        else
            return KColorUtils::mix(d->titleBarColor(), d->fontColor(), 0.3);

    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade) &&
               isChecked()) {
        return d->fontColor();

    } else if (m_animation->state() == QAbstractAnimation::Running) {
        if (type() == DecorationButtonType::Close) {
            QColor color(c->color(ColorGroup::Warning, ColorRole::Foreground).lighter());
            color.setAlpha(color.alpha() * m_opacity);
            return color;

        } else {
            QColor color(d->fontColor());
            color.setAlpha(color.alpha() * m_opacity);
            return color;
        }

    } else if (this->hovered()) {
        if (type() == DecorationButtonType::Close)
            return c->color(ColorGroup::Warning, ColorRole::Foreground).lighter();
        else
            return d->fontColor();

    } else {
        return QColor();
    }
}

//__________________________________________________________________
qreal Button::buttonRadius() const {
    auto d = qobject_cast<Decoration *>(decoration());

    if (d->internalSettings()->animationsEnabled() && (!isChecked() || (isChecked() && type() == DecorationButtonType::Maximize))) {
        return static_cast<qreal>(7) + static_cast<qreal>(1) * m_animation->currentValue().toReal();
    } else
        return static_cast<qreal>(9);
}

//__________________________________________________________________
QColor Button::autoColor(const bool inactiveWindow, const bool useActiveButtonStyle, const bool useInactiveButtonStyle, const QColor darkSymbolColor,
                         const QColor lightSymbolColor) const {
    QColor col;

    if (useActiveButtonStyle || (!inactiveWindow && !useInactiveButtonStyle))
        col = darkSymbolColor;
    else {
        auto d = qobject_cast<Decoration *>(decoration());
        QColor titleBarColor(d->titleBarColor());

        uint r = qRed(titleBarColor.rgb());
        uint g = qGreen(titleBarColor.rgb());
        uint b = qBlue(titleBarColor.rgb());

        // modified from https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
        // qreal titleBarLuminance = (0.2126 * static_cast<qreal>(r) + 0.7152 * static_cast<qreal>(g) + 0.0722 * static_cast<qreal>(b)) / 255.;
        // if ( titleBarLuminance >  sqrt(1.05 * 0.05) - 0.05 )
        qreal colorConditional = 0.299 * static_cast<qreal>(r) + 0.587 * static_cast<qreal>(g) + 0.114 * static_cast<qreal>(b);
        if (colorConditional > 186 || g > 186)
            col = darkSymbolColor;
        else
            col = lightSymbolColor;
    }
    return col;
}

//__________________________________________________________________
bool Button::hovered() const {
    auto d = qobject_cast<Decoration *>(decoration());
    return isHovered() || d->buttonHovered();
}

//________________________________________________________________
void Button::reconfigure() {
    // animation
    auto d = qobject_cast<Decoration *>(decoration());
    if (d) m_animation->setDuration(d->internalSettings()->animationsDuration());
}

//__________________________________________________________________
void Button::updateAnimationState(bool hovered) {
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d || !d->internalSettings()->animationsEnabled()) return;

    QAbstractAnimation::Direction dir = hovered ? QAbstractAnimation::Forward : QAbstractAnimation::Backward;
    if (m_animation->state() == QAbstractAnimation::Running && m_animation->direction() != dir) m_animation->stop();
    m_animation->setDirection(dir);
    if (m_animation->state() != QAbstractAnimation::Running) m_animation->start();
}

}  // namespace Breeze
