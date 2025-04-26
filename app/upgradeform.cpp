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

#include "upgradeform.h"
#include "ui_upgradeform.h"

#include "messagebox.h"

UpgradeForm::UpgradeForm(QWidget *parent,AppData* data,AppLogic* logic) :
    QWidget(parent),
    ui(new Ui::UpgradeForm)
{


    this->data = data;
    this->logic = logic;

    ui->setupUi(this);

    connect(ui->nextBtn, SIGNAL( clicked()), this, SLOT( OnNext() ) );
    connect(ui->prevBtn, SIGNAL( clicked()), this, SLOT( OnPrev() ) );
    connect(ui->abortBtn, SIGNAL( clicked()), this, SLOT( OnAbort() ) );

    connect(ui->upgradeBtn, SIGNAL( clicked()), this, SLOT( on_checkBox_clicked() ) );
    connect(ui->newBtn, SIGNAL( clicked()), this, SLOT( on_checkBox_clicked() ) );

    QString message;
    message += "<html>";
    message += "A previous installation of PetaSAN version <b>";
    message += data->prev_install_version;
    message += "</b> was detected on disk <b>";
    message += data->prev_install_disk;
    message += "</b>.</html>";

   ui->infoLabel->setWordWrap(true);
   ui->infoLabel->setText(message);
   /*
   if( data->can_upgrade  ) {

       ui->upgradeBtn->setChecked(true);
       ui->newBtn->setChecked(false);
   }
   else {

       ui->upgradeBtn->setChecked(false);
       ui->upgradeBtn->setEnabled(false);
       ui->upgradeLabel->setEnabled(false);
       ui->newBtn->setChecked(true);
   }
   */

   ui->upgradeBtn->setChecked(true);
   ui->newBtn->setChecked(false);
   ui->nextBtn->setEnabled(false);
   ui->prevBtn->setEnabled(false);
}


void UpgradeForm::on_checkBox_clicked()
{
    if( ui->newBtn->isChecked() ) {
        ui->nextBtn->setEnabled(true);
        ui->prevBtn->setEnabled(true);
    }
    else {
        ui->nextBtn->setEnabled(false);
        ui->prevBtn->setEnabled(false);
    }
}

UpgradeForm::~UpgradeForm()
{
    delete ui;
}


void UpgradeForm::OnNext()
{
    /*
    QString mess = "Proceed with Upgrade ?";

    if ( !ui->newBtn->isChecked() && !MessageBox::confirm(mess) )
         return;

    data->new_install =  ui->newBtn->isChecked();
    emit nextBtnEvent();
    */

    if ( !ui->newBtn->isChecked() )
         return; // should not occur

    QString mess = "Proceed with New installation. Erasing data ?";

    if ( !MessageBox::confirm(mess) )
         return;

    data->new_install =  true;
    emit nextBtnEvent();

}

void UpgradeForm::OnPrev()
{
    emit prevBtnEvent();
}

void UpgradeForm::OnAbort()
{
     emit abortBtnEvent();
}
