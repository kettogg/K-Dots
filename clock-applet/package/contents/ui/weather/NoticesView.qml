/*
 * Copyright 2012  Luís Gabriel Lima <lampih@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1

Column {
    id: root

    property var model

    spacing: units.largeSpacing
    visible: model.length > 0 && model[0].length > 0 && model[1].length > 0

    Notice {
        title: i18nc("weather warnings", "Warnings Issued:")
        model: root.model[0]
    }

    Notice {
        title: i18nc("weather watches" ,"Watches Issued:")
        model: root.model[1]
    }
}
