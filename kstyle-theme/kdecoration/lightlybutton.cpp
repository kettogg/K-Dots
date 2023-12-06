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
#include "lightlybutton.h"

#include <KColorUtils>
#include <KDecoration2/DecoratedClient>
#include <KIconLoader>

#include <QPainter>
#include <QPainterPath>
#include <QVariantAnimation>

namespace Lightly
{
using KDecoration2::ColorGroup;
using KDecoration2::ColorRole;
using KDecoration2::DecorationButtonType;

//__________________________________________________________________
Button::Button(DecorationButtonType type, Decoration *decoration, QObject *parent)
    : DecorationButton(type, decoration, parent)
    , m_animation(new QVariantAnimation(this))
{
    // setup animation
    // It is important start and end value are of the same type, hence 0.0 and not just 0
    m_animation->setStartValue(0.0);
    m_animation->setEndValue(1.0);
    m_animation->setEasingCurve(QEasingCurve::InOutQuad);
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        setOpacity(value.toReal());
    });

    // setup default geometry
    const int height = decoration->buttonHeight();
    setGeometry(QRect(0, 0, height, height));
    setIconSize(QSize(height, height));

    // connections
    connect(decoration->client().data(), SIGNAL(iconChanged(QIcon)), this, SLOT(update()));
    connect(decoration->settings().data(), &KDecoration2::DecorationSettings::reconfigured, this, &Button::reconfigure);
    connect(this, &KDecoration2::DecorationButton::hoveredChanged, this, &Button::updateAnimationState);

    if (decoration->objectName() == "applet-window-buttons") {
        connect(this, &Button::hoveredChanged, [=](bool hovered) {
            decoration->setButtonHovered(hovered);
        });
    }
    connect(decoration, SIGNAL(buttonHoveredChanged()), this, SLOT(update()));

    reconfigure();
}

//__________________________________________________________________
Button::Button(QObject *parent, const QVariantList &args)
    : Button(args.at(0).value<DecorationButtonType>(), args.at(1).value<Decoration *>(), parent)
{
    m_flag = FlagStandalone;
    //! icon size must return to !valid because it was altered from the default constructor,
    //! in Standalone mode the button is not using the decoration metrics but its geometry
    m_iconSize = QSize(-1, -1);
}

//__________________________________________________________________
Button *Button::create(DecorationButtonType type, KDecoration2::Decoration *decoration, QObject *parent)
{
    if (auto d = qobject_cast<Decoration *>(decoration)) {
        Button *b = new Button(type, d, parent);
        switch (type) {
        case DecorationButtonType::Close:
            b->setVisible(d->client().data()->isCloseable());
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::closeableChanged, b, &Lightly::Button::setVisible);
            break;

        case DecorationButtonType::Maximize:
            b->setVisible(d->client().data()->isMaximizeable());
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::maximizeableChanged, b, &Lightly::Button::setVisible);
            break;

        case DecorationButtonType::Minimize:
            b->setVisible(d->client().data()->isMinimizeable());
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::minimizeableChanged, b, &Lightly::Button::setVisible);
            break;

        case DecorationButtonType::ContextHelp:
            b->setVisible(d->client().data()->providesContextHelp());
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::providesContextHelpChanged, b, &Lightly::Button::setVisible);
            break;

        case DecorationButtonType::Shade:
            b->setVisible(d->client().data()->isShadeable());
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::shadeableChanged, b, &Lightly::Button::setVisible);
            break;

        case DecorationButtonType::Menu:
            QObject::connect(d->client().data(), &KDecoration2::DecoratedClient::iconChanged, b, [b]() {
                b->update();
            });
            break;

        default:
            break;
        }

        return b;
    }

    return nullptr;
}

//__________________________________________________________________
void Button::paint(QPainter *painter, const QRect &repaintRegion)
{
    Q_UNUSED(repaintRegion)

    if (!decoration())
        return;

    painter->save();

    // translate from offset
    if (m_flag == FlagFirstInList)
        painter->translate(m_offset);
    else
        painter->translate(0, m_offset.y());

    if (!m_iconSize.isValid())
        m_iconSize = geometry().size().toSize();

    // menu button
    if (type() == DecorationButtonType::Menu) {
        const QRectF iconRect(geometry().topLeft(), m_iconSize);
        if (auto deco = qobject_cast<Decoration *>(decoration())) {
            const QPalette activePalette = KIconLoader::global()->customPalette();
            QPalette palette = decoration()->client().data()->palette();
            palette.setColor(QPalette::Foreground, deco->fontColor());
            KIconLoader::global()->setCustomPalette(palette);
            decoration()->client().data()->icon().paint(painter, iconRect.toRect());
            if (activePalette == QPalette()) {
                KIconLoader::global()->resetPalette();
            } else {
                KIconLoader::global()->setCustomPalette(palette);
            }
        } else {
            decoration()->client().data()->icon().paint(painter, iconRect.toRect());
        }

    } else {
        drawIcon(painter);
    }

    painter->restore();
}

//__________________________________________________________________
void Button::drawIcon(QPainter *painter) const
{
    painter->setRenderHints(QPainter::Antialiasing);

    /*
    scale painter so that its window matches QRect( -1, -1, 20, 20 )
    this makes all further rendering and scaling simpler
    all further rendering is preformed inside QRect( 0, 0, 18, 18 )
    */
    painter->translate(geometry().topLeft());

    const qreal width(m_iconSize.width());
    auto d = qobject_cast<Decoration *>(decoration());
    if (d->internalSettings()->animationsEnabled()) {
        painter->scale(width / 20, width / 20);
        painter->translate(1, 1);
    } else {
        painter->scale(7. / 9. * width / 20, 7. / 9. * width / 20);
        painter->translate(4, 4);
    }

    bool inactiveWindow(d && !d->client().toStrongRef().data()->isActive());

    QColor darkSymbolColor(inactiveWindow ? QColor(81, 102, 107) : QColor(34, 45, 50));
    QColor lightSymbolColor(inactiveWindow ? QColor(192, 193, 194) : QColor(250, 251, 252));

    QColor titleBarColor(d->titleBarColor());

    // symbols color

    QColor symbolColor;
    if (inactiveWindow && qGray(titleBarColor.rgb()) < 128)
        symbolColor = lightSymbolColor;
    else if (inactiveWindow && qGray(titleBarColor.rgb()) > 128)
        symbolColor = darkSymbolColor;
    else
        symbolColor = this->autoColor(false, true, false, darkSymbolColor, lightSymbolColor);

    // symbols pen

    QPen symbol_pen(symbolColor);
    symbol_pen.setJoinStyle(Qt::MiterJoin);
    if (d->internalSettings()->animationsEnabled())
        symbol_pen.setWidthF(1.7 * qMax((qreal)1.0, 20 / width));
    else
        symbol_pen.setWidthF(9. / 7. * 1.7 * qMax((qreal)1.0, 20 / width));

    switch (type()) {
    case DecorationButtonType::Close: {
        QColor button_color;
        if (!inactiveWindow && qGray(titleBarColor.rgb()) < 128)
            //<>button_color = QColor(238, 102, 90);
            button_color = QColor(240, 98, 146);
        else if (!inactiveWindow)
            // button_color = QColor(255, 94, 88);
            button_color = QColor(240, 98, 146);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);
        if (this->hovered()) {
            painter->setPen(symbol_pen);
            // it's a cross
            painter->drawLine(QPointF(6, 6), QPointF(12, 12));
            painter->drawLine(QPointF(6, 12), QPointF(12, 6));
        }
        break;
    }

    case DecorationButtonType::Maximize: {
        QColor button_color;
        if (!inactiveWindow && qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(66, 165, 245);
        else if (!inactiveWindow)
            button_color = QColor(66, 165, 245);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);
        if (this->hovered()) {
            painter->setPen(Qt::NoPen);

            // two triangles
            QPainterPath path1, path2;
            if (isChecked()) {
                path1.moveTo(8.5, 9.5);
                path1.lineTo(2.5, 9.5);
                path1.lineTo(8.5, 15.5);

                path2.moveTo(9.5, 8.5);
                path2.lineTo(15.5, 8.5);
                path2.lineTo(9.5, 2.5);
            } else {
                path1.moveTo(5, 13);
                path1.lineTo(11, 13);
                path1.lineTo(5, 7);

                path2.moveTo(13, 5);
                path2.lineTo(7, 5);
                path2.lineTo(13, 11);
            }

            painter->fillPath(path1, QBrush(symbolColor));
            painter->fillPath(path2, QBrush(symbolColor));
        }
        break;
    }

    case DecorationButtonType::Minimize: {
        QColor button_color;
        if (!inactiveWindow && qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(77, 208, 225);
        else if (!inactiveWindow)
            button_color = QColor(77, 208, 225);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);
        if (this->hovered()) {
            painter->setPen(symbol_pen);
            painter->drawLine(QPointF(5, 9), QPointF(13, 9));
        }
        break;
    }

    case DecorationButtonType::OnAllDesktops: {
        QColor button_color;
        if (!inactiveWindow)
            button_color = QColor(128, 203, 196);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);

        if (this->hovered() || isChecked()) {
            painter->setPen(Qt::NoPen);
            painter->setBrush(QBrush(symbolColor));
            painter->drawEllipse(QRectF(6, 6, 6, 6));
        }
        break;
    }

    case DecorationButtonType::Shade: {
        QColor button_color;
        if (!inactiveWindow)
            button_color = QColor(204, 176, 213);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);

        if (isChecked()) {
            painter->setPen(symbol_pen);
            painter->drawLine(QPointF(6, 12), QPointF(12, 12));
            painter->setPen(Qt::NoPen);
            QPainterPath path;
            path.moveTo(9, 11);
            path.lineTo(5, 6);
            path.lineTo(13, 6);
            painter->fillPath(path, QBrush(symbolColor));

        } else if (this->hovered()) {
            painter->setPen(symbol_pen);
            painter->drawLine(QPointF(6, 6), QPointF(12, 6));
            painter->setPen(Qt::NoPen);
            QPainterPath path;
            path.moveTo(9, 7);
            path.lineTo(5, 12);
            path.lineTo(13, 12);
            painter->fillPath(path, QBrush(symbolColor));
        }
        break;
    }

    case DecorationButtonType::KeepBelow: {
        QColor button_color;
        if (!inactiveWindow)
            button_color = QColor(255, 137, 241);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);

        if (this->hovered() || isChecked()) {
            painter->setPen(Qt::NoPen);

            QPainterPath path;
            path.moveTo(9, 12);
            path.lineTo(5, 6);
            path.lineTo(13, 6);
            painter->fillPath(path, QBrush(symbolColor));
        }
        break;
    }

    case DecorationButtonType::KeepAbove: {
        QColor button_color;
        if (!inactiveWindow)
            button_color = QColor(135, 206, 249);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);

        if (this->hovered() || isChecked()) {
            painter->setPen(Qt::NoPen);

            QPainterPath path;
            path.moveTo(9, 6);
            path.lineTo(5, 12);
            path.lineTo(13, 12);
            painter->fillPath(path, QBrush(symbolColor));
        }
        break;
    }

    case DecorationButtonType::ApplicationMenu: {
        QColor menuSymbolColor;

        uint r = qRed(titleBarColor.rgb());
        uint g = qGreen(titleBarColor.rgb());
        uint b = qBlue(titleBarColor.rgb());
        // modified from https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
        // qreal titleBarLuminance = (0.2126 * static_cast<qreal>(r) + 0.7152 * static_cast<qreal>(g) + 0.0722 * static_cast<qreal>(b)) / 255.;
        // if ( titleBarLuminance >  sqrt(1.05 * 0.05) - 0.05 )
        qreal colorConditional = 0.299 * static_cast<qreal>(r) + 0.587 * static_cast<qreal>(g) + 0.114 * static_cast<qreal>(b);
        if (colorConditional > 186 || g > 186)
            menuSymbolColor = darkSymbolColor;
        else
            menuSymbolColor = lightSymbolColor;

        QPen menuSymbol_pen(menuSymbolColor);
        menuSymbol_pen.setJoinStyle(Qt::MiterJoin);
        menuSymbol_pen.setWidthF(1.7 * qMax((qreal)1.0, 20 / width));

        painter->setPen(menuSymbol_pen);

        painter->drawLine(QPointF(3.5, 5), QPointF(14.5, 5));
        painter->drawLine(QPointF(3.5, 9), QPointF(14.5, 9));
        painter->drawLine(QPointF(3.5, 13), QPointF(14.5, 13));

        break;
    }

    case DecorationButtonType::ContextHelp: {
        QColor button_color;
        if (!inactiveWindow)
            button_color = QColor(102, 156, 246);
        else if (qGray(titleBarColor.rgb()) < 128)
            button_color = QColor(100, 100, 100);
        else
            button_color = QColor(200, 200, 200);
        QPen button_pen(qGray(titleBarColor.rgb()) < 69 ? button_color.lighter(115) : button_color.darker(115));
        button_pen.setJoinStyle(Qt::MiterJoin);
        if (d->internalSettings()->animationsEnabled())
            button_pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        else
            button_pen.setWidthF(9. / 7. * PenWidth::Symbol * qMax((qreal)1.0, 20 / width));
        painter->setBrush(button_color);
        painter->setPen(button_pen);

        qreal r = this->buttonRadius();
        QPointF c(static_cast<qreal>(9), static_cast<qreal>(9));
        painter->drawEllipse(c, r, r);
        painter->setBrush(Qt::NoBrush);

        if (this->hovered() || isChecked()) {
            painter->setPen(symbol_pen);
            QPainterPath path;
            path.moveTo(6, 6);
            path.arcTo(QRectF(5.5, 4, 7.5, 4.5), 180, -180);
            path.cubicTo(QPointF(11, 9), QPointF(9, 6), QPointF(9, 10));
            painter->drawPath(path);
            painter->drawPoint(9, 13);
        }
        break;
    }

    default:
        break;
    }
}

//__________________________________________________________________
QColor Button::autoColor(const bool inactiveWindow,
                         const bool useActiveButtonStyle,
                         const bool useInactiveButtonStyle,
                         const QColor darkSymbolColor,
                         const QColor lightSymbolColor) const
{
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
QColor Button::foregroundColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();

    } else if (true) {
        return QColor("white");
    } else if (isPressed()) {
        return d->titleBarColor();
    } else if (type() == DecorationButtonType::Close && d->internalSettings()->outlineCloseButton()) {
        return d->titleBarColor();
    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade)
               && isChecked()) {
        return d->titleBarColor();
    } else if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(d->fontColor(), d->titleBarColor(), m_opacity);
    } else if (isHovered()) {
        return d->titleBarColor();
    } else {
        return d->fontColor();
    }
}

//__________________________________________________________________
QColor Button::backgroundColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();
    }
    auto c = d->client().data();
    if (isPressed()) {
        if (type() == DecorationButtonType::Close)
            return c->color(ColorGroup::Warning, ColorRole::Foreground);
        else
            return KColorUtils::mix(d->titleBarColor(), d->fontColor(), 0.3);

    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade)
               && isChecked()) {
        return d->fontColor();

    } else if (m_animation->state() == QAbstractAnimation::Running) {
        if (type() == DecorationButtonType::Close) {
            if (d->internalSettings()->outlineCloseButton()) {
                return KColorUtils::mix(d->fontColor(), c->color(ColorGroup::Warning, ColorRole::Foreground).lighter(), m_opacity);

            } else {
                QColor color(c->color(ColorGroup::Warning, ColorRole::Foreground).lighter());
                color.setAlpha(color.alpha() * m_opacity);
                return color;
            }

        } else {
            QColor color(d->fontColor());
            color.setAlpha(color.alpha() * m_opacity);
            return color;
        }

    } else if (isHovered()) {
        if (type() == DecorationButtonType::Close)
            return c->color(ColorGroup::Warning, ColorRole::Foreground).lighter();
        else
            return d->fontColor();

    } else if (type() == DecorationButtonType::Close && d->internalSettings()->outlineCloseButton()) {
        return d->fontColor();

    } else {
        return QColor();
    }
}
//__________________________________________________________________
qreal Button::buttonRadius() const
{
    auto d = qobject_cast<Decoration *>(decoration());

    if (d->internalSettings()->animationsEnabled() && (!isChecked() || (isChecked() && type() == DecorationButtonType::Maximize))) {
        return static_cast<qreal>(7) + static_cast<qreal>(2) * m_animation->currentValue().toReal();
    } else
        return static_cast<qreal>(9);
}

//__________________________________________________________________
bool Button::hovered() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    return isHovered() || d->buttonHovered();
}

//________________________________________________________________
void Button::reconfigure()
{
    // animation
    auto d = qobject_cast<Decoration *>(decoration());
    if (d)
        m_animation->setDuration(d->internalSettings()->animationsDuration());
}

//__________________________________________________________________
void Button::updateAnimationState(bool hovered)
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!(d && d->internalSettings()->animationsEnabled()))
        return;

    m_animation->setDirection(hovered ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
    if (m_animation->state() != QAbstractAnimation::Running)
        m_animation->start();
}

} // namespace
