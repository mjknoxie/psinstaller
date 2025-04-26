/*
 Copyright (C) 2025 Maged Mokhtar <mmokhtar <at> petasan.org>
 Copyright (C) 2025 PetaSAN www.petasan.org


 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 */

#ifndef MESSAGEBOX_H
#define MESSAGEBOX_H


#include <QMessageBox>
#include <QWidget>

class MessageBox
{
public:
    static void warn(QString message);
    static bool confirm(QString message);
protected:
    static void show(QWidget* w);
};

#endif // MESSAGEBOX_H
