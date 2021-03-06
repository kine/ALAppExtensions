codeunit 1872 "C5 Telemetry"
{
    var
        EmptyZipFileBlobErr: Label 'Oops, it seems the blob is empty.';
        CopyToDatabaseFailedErr: Label 'Something went wrong with copying the zip file to Database.';

        StagingTablesImportStartTxt: Label 'CSV file import to staging tables started.', Locked = true;

        StagingTablesImportFinishTxt: Label 'CSV file import to staging tables finished; duration: %1', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnZipFileBlobMissing', '', false, false)]
    local procedure OnZipFileBlobMissingSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DF', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, EmptyZipFileBlobErr, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Data Migration Mgt.", 'OnCopyToDataBaseFailed', '', false, false)]
    local procedure OnCopyToDataBaseFailedSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001IK', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, CopyToDatabaseFailedErr, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Unzip", 'OnUnzipFileError', '', false, false)]
    local procedure OnUnzipFileErrorSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001IL', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, GetLastErrorText(), DataClassification::CustomerContent);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Schema Reader", 'OnDefinitionFileMissing', '', false, false)]
    local procedure OnDefinitionFileMissinggSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        C5SchemaReader: Codeunit "C5 Schema Reader";
    begin
        SendTraceTag('00001DG', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, C5SchemaReader.GetDefinitionFileMissingErrorTxt(), DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Data Loader", 'OnFillStagingTablesStarted', '', false, false)]
    local procedure OnFillStagingTablesStartedubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001HZ', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Normal, StagingTablesImportStartTxt, DataClassification::SystemMetadata);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Data Loader", 'OnFillStagingTablesFinished', '', false, false)]
    local procedure OnFillStagingTablesFinishedSubscriber(DurationAsInt: Integer)
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001I0',
                 C5MigrationDashboardMgt.GetC5MigrationTypeTxt(),
                 Verbosity::Normal,
                 StrSubstNo(StagingTablesImportFinishTxt, DurationAsInt),
                 DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Wizard Integration", 'OnC5MigrationSelected', '', false, false)]
    local procedure OnC5MigrationSelectedSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001K5', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), Verbosity::Normal, 'C5 Migration was selected.', DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Wizard Integration", 'OnEntitiesToMigrateSelected', '', false, false)]
    local procedure OnEntitiesToMigrateSelectedSubscriber(var DataMigrationEntity: Record "Data Migration Entity")
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        EntitiesToMigrateMessage: Text;
    begin
        DataMigrationEntity.SetRange(Selected, true);
        DataMigrationEntity.SetRange("Table ID", Database::Vendor);

        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('vendor: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Customer);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('customer: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::"G/L Account");
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('gl_acc: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Item);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('item: %1; ', DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::"C5 LedTrans");
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo('C5_ledger_entries: %1; ', DataMigrationEntity."No. of Records");

        SendTraceTag('00001I1', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), Verbosity::Normal, EntitiesToMigrateMessage, DataClassification::SystemMetadata);
    end;
}