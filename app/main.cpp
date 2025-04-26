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

#include "mainwindow.h"
#include <QApplication>
#include <QFont>
#include <QStyleFactory>
#include <QSplashScreen>
#include <unistd.h>
#include "applogic.h"
#include "appdata.h"

#include "messagebox.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QString message;

    a.setFont(QFont("Sans Serif", 10));
    //("Windows", "Motif", "CDE", "Plastique", "GTK+", "Cleanlooks")
    a.setStyle(QStyleFactory::create("Windows"));

    QPixmap pixmap = QPixmap(":/images/resources/splash.png" );
    QSplashScreen splash(pixmap);
    splash.show();
    a.processEvents();
    usleep( 500 * 1000);
    message = " Scanning for previous installations...";
    splash.showMessage(message,Qt::AlignLeft | Qt::AlignBottom, Qt::black);
    a.processEvents();
    usleep( 2000 * 1000);

    AppData data;
    AppLogic logic;

    data.new_install = true;
    data.prev_install_disk =  logic.getPrevInstallDisk();
    data.prev_install_version = logic.getPrevInstallVersion();
    data.can_upgrade = logic.canUpgrade(data.prev_install_version );


    if( data.prev_install_version.isEmpty() ) {
        message = " No previous installations found.";
    } else {
        message = " Found previous version " + data.prev_install_version;
    }

    splash.showMessage(message,Qt::AlignLeft | Qt::AlignBottom, Qt::black);
    a.processEvents();
    usleep( 2000 * 1000);

    a.setFont(QFont("Sans Serif", 11));

    /*
    if( !data.prev_install_version.isEmpty() ) {
        QString message;
        message += "<html>";
        message += "<p>A previous installation of PetaSAN version <b>";
        message += data.prev_install_version;
        message += "</b> was detected on disk <b>";
        message += data.prev_install_disk;
        message += "</b>.</p>";
        message += "<p>For upgrades refer to the online upgrade guide.</p>";
        message += "</html>";

        MessageBox::warn(message);
        //qApp->exit();
        return -1;
    }
    */

    MainWindow w(0,&data,&logic);
    w.show();

    splash.finish(&w);
    return a.exec();
}
