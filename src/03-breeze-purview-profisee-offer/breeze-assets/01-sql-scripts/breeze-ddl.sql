SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE SCHEMA [breeze];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[ADFConfigTableList]
    (
        [ADFConfigTableListId]           [INT]           IDENTITY(1, 1) NOT NULL
        , [SystemName]                   [VARCHAR](50)   NOT NULL
        , [Source]                       [VARCHAR](50)   NOT NULL
        , [Destination]                  [VARCHAR](50)   NOT NULL
        , [SrcDbOrContainer]             [VARCHAR](50)   NOT NULL
        , [SrcObjectType]                [VARCHAR](50)   NULL
        , [SrcSchemaOrFolder]            [VARCHAR](255)  NOT NULL
        , [SrcObjectName]                [VARCHAR](255)  NOT NULL
        , [SrcQuery]                     [VARCHAR](2000) NULL
        , [SrcConnectionStrSecretOrURL]  [VARCHAR](255)  NULL
        , [SrcUsername]                  [VARCHAR](255)  NULL
        , [SrcPasswordSecret]            [VARCHAR](255)  NULL
        , [DestDbOrContainer]            [VARCHAR](50)   NOT NULL
        , [DestObjectType]               [VARCHAR](50)   NULL
        , [DestSchemaOrFolder]           [VARCHAR](255)  NOT NULL
        , [DestObjectName]               [VARCHAR](255)  NOT NULL
        , [DestQuery]                    [VARCHAR](2000) NULL
        , [DestConnectionStrSecretOrURL] [VARCHAR](255)  NULL
        , [DestUsername]                 [VARCHAR](255)  NULL
        , [DestPasswordSecret]           [VARCHAR](255)  NULL
        , [LoadType]                     [VARCHAR](50)   NOT NULL
        , [QualifiedColumnForFilter]     [VARCHAR](500)  NULL
        , [FilterDefaultValue]           [VARCHAR](100)  NULL
        , [LoadStatus]                   [VARCHAR](10)   NULL
        , [LoadRunDate]                  [DATETIME]      NULL
        , [IsActive]                     [BIT]           NOT NULL
        , CONSTRAINT [PK_ADFConfigTableList]
              PRIMARY KEY NONCLUSTERED ([ADFConfigTableListId] ASC) NOT ENFORCED
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[ADFStoredProcList]
    (
        [ADFStoredProcListId]   [INT]          IDENTITY(1, 1) NOT NULL
        , [SystemName]          [VARCHAR](50)  NOT NULL
        , [LoadType]            [NVARCHAR](20) NOT NULL
        , [ExecOrder]           [TINYINT]      NOT NULL
        , [StoredProcedureName] [VARCHAR](100) NOT NULL
        , [RunStatus]           [VARCHAR](10)  NULL
        , [LastAdfRunDate]      [DATETIME]     NULL
        , [IsActive]            [BIT]          NOT NULL
        , CONSTRAINT [PK_ADFStoredProcListId]
              PRIMARY KEY NONCLUSTERED ([ADFStoredProcListId] ASC) NOT ENFORCED
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[ADFTableList]
    (
        [ADFConfigTableListId]           [INT]           IDENTITY(1, 1) NOT NULL
        , [ADFTableListId]               [VARCHAR](50)   NOT NULL
        , [SystemName]                   [VARCHAR](50)   NOT NULL
        , [Source]                       [VARCHAR](50)   NOT NULL
        , [Destination]                  [VARCHAR](50)   NOT NULL
        , [SrcDbOrContainer]             [VARCHAR](50)   NOT NULL
        , [SrcObjectType]                [VARCHAR](50)   NULL
        , [SrcSchemaOrFolder]            [VARCHAR](255)  NOT NULL
        , [SrcObjectName]                [VARCHAR](255)  NOT NULL
        , [SrcQuery]                     [VARCHAR](2000) NULL
        , [SrcConnectionStrSecretOrURL]  [VARCHAR](255)  NULL
        , [SrcUsername]                  [VARCHAR](255)  NULL
        , [SrcPasswordSecret]            [VARCHAR](255)  NULL
        , [DestDbOrContainer]            [VARCHAR](50)   NOT NULL
        , [DestObjectType]               [VARCHAR](50)   NULL
        , [DestSchemaOrFolder]           [VARCHAR](255)  NOT NULL
        , [DestObjectName]               [VARCHAR](255)  NOT NULL
        , [DestQuery]                    [VARCHAR](2000) NULL
        , [DestConnectionStrSecretOrURL] [VARCHAR](255)  NULL
        , [DestUsername]                 [VARCHAR](255)  NULL
        , [DestPasswordSecret]           [VARCHAR](255)  NULL
        , [LoadType]                     [VARCHAR](50)   NOT NULL
        , [QualifiedColumnForFilter]     [VARCHAR](500)  NULL
        , [FilterDefaultValue]           [VARCHAR](100)  NULL
        , [LoadStatus]                   [VARCHAR](10)   NULL
        , [LoadRunDate]                  [DATETIME]      NULL
        , [IsActive]                     [BIT]           NOT NULL
        , [CustomQueryFunction]          [VARCHAR](100)  NULL
        , [AdlsLoadStatus]               [VARCHAR](10)   NULL
        , [AdlsLoadRunDate]              [DATETIME]      NULL
        , [StagingLoadStatus]            [VARCHAR](10)   NULL
        , [StagingLoadRunDate]           [DATETIME]      NULL
        , [StgAccountName]               [VARCHAR](50)   NULL
        , [SourceDBName]                 [VARCHAR](25)   NULL
        , CONSTRAINT [PK_ADFTableList]
              PRIMARY KEY NONCLUSTERED ([ADFConfigTableListId] ASC) NOT ENFORCED
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[Audit_ConfigMaster]
    (
        [Type]                 [VARCHAR](100) NOT NULL
        , [Value]              [VARCHAR](200) NULL
        , [dtLastModifiedDate] [DATETIME]     NULL
        , CONSTRAINT [PK_Audit_ConfigMaster]
              PRIMARY KEY NONCLUSTERED ([Type] ASC) NOT ENFORCED
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[Audit_ExecutionLog]
    (
        [DWBatchId]        [INT]           NULL
        , [ETLBatchID]     [INT]           IDENTITY(1, 1) NOT NULL
        , [Description]    [VARCHAR](100)  NULL
        , [BatchName]      [VARCHAR](50)   NOT NULL
        , [BatchStart]     [VARCHAR](50)   NULL
        , [BatchEnd]       [DATETIME]      NULL
        , [ProcessDate]    [SMALLDATETIME] NOT NULL
        , [Operator]       [VARCHAR](50)   NOT NULL
        , [StartTime]      [SMALLDATETIME] NOT NULL
        , [EndTime]        [SMALLDATETIME] NULL
        , [Status]         [TINYINT]       NOT NULL
        , [FailureTask]    [VARCHAR](1024) NULL
        , [ErrorMessage]   [VARCHAR](4000) NULL
        , [SourceCount]    [INT]           NULL
        , [StageCount]     [INT]           NULL
        , [InsertCount]    [INT]           NULL
        , [UpdateCount]    [INT]           NULL
        , [UnchangedCount] [INT]           NULL
        , [ErrorCount]     [INT]           NULL
        , [TargetCount]    [INT]           NULL
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[Audit_ExecutionTracking]
    (
        [TrackingID]       [INT]          IDENTITY(1, 1) NOT NULL
        , [ETLBatchID]     [INT]          NULL
        , [dtProcessDate]  [DATETIME]     NULL
        , [ObjectName]     [VARCHAR](500) NULL
        , [StepNo]         [INT]          NULL
        , [StageDesc]      [VARCHAR](500) NULL
        , [StageTimestamp] [DATETIME]     NULL
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[BreezeTransformConfig]
    (
        [TransformID]            [INT]          IDENTITY(1, 1) NOT NULL
        , [ObjectName]           [VARCHAR](500) NULL
        , [FieldName]            [VARCHAR](100) NULL
        , [TransformName]        [VARCHAR](100) NULL
        , [InputValue]           [VARCHAR](100) NULL
        , [ADFConfigTableListId] [INT]          NULL
        , CONSTRAINT [PK_BreezeTransformConfig_TransformID]
              PRIMARY KEY NONCLUSTERED ([TransformID] ASC) NOT ENFORCED
    );
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [breeze].[DWBatch]
    (
        [DWBatchId]              [INT]         IDENTITY(1, 1) NOT NULL
        , [DWBatchStartDateTime] [DATETIME]    NULL
        , [DWBatchEndDateTime]   [DATETIME]    NULL
        , [DWBatchStatus]        [INT]         NULL
        , [SystemName]           [NCHAR](10)   NULL
        , [DWState]              [VARCHAR](10) NULL
        , [DWAdlsLoad]           [BIT]         NULL
        , [DWStageLoad]          [BIT]         NULL
        , [DWLoad]               [BIT]         NULL
        , [DWReportLoad]         [BIT]         NULL
        ,
        PRIMARY KEY NONCLUSTERED ([DWBatchId] ASC) NOT ENFORCED
    );
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [breeze].[usp_AddAuditLog]
    @DWBatchId       INT
    , @ETLBatchID    INT
    , @dtProcessDate DATETIME
    , @ObjectName    VARCHAR(500)
    , @StepNo        INT
    , @StageDesc     VARCHAR(500)
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @AuditTrackingYN VARCHAR(10);

        SELECT
            @AuditTrackingYN = Value
        FROM
            [breeze].[Audit_ConfigMaster]
        WHERE
            UPPER(Type) = UPPER('AuditTrackingYN');

        IF (ISNULL(@AuditTrackingYN, 'N') = 'Y')
            BEGIN
                INSERT INTO [breeze].[Audit_ExecutionTracking]
                    (
                        [ETLBatchID]
                        , [dtProcessDate]
                        , [ObjectName]
                        , [StepNo]
                        , [StageDesc]
                        , [StageTimestamp]
                    )
                VALUES
                    (
                        @ETLBatchID, @dtProcessDate, @ObjectName, @StepNo, @StageDesc, GETDATE()
                    );
            END;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_ADFProcess_OnBegin]
    @DWBatchId     INT
    , @Description VARCHAR(100)
    , @BatchName   VARCHAR(50)
    , @BatchStart  DATETIME
    , @ProcessDate DATETIME
    , @operator    VARCHAR(30)
    , @StartTime   DATETIME
    , @ETLBatchID  INT OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY

            SET @ProcessDate = ISNULL(@ProcessDate, GETDATE());
            SET @operator = NULLIF(LTRIM(RTRIM(@operator)), '');
            SET @operator = ISNULL(@operator, SUSER_SNAME());
            SET @StartTime = GETDATE();

            INSERT INTO [breeze].[Audit_ExecutionLog]
                (
                    DWBatchId
                    , [Description]
                    , [BatchName]
                    , [BatchStart]
                    , [ProcessDate]
                    , [Operator]
                    , [StartTime]
                    , [EndTime]
                    , [Status]
                    , [ErrorMessage]
                )
            VALUES
                (
                    @DWBatchId, @Description, @BatchName, @BatchStart, @ProcessDate, @operator, GETDATE(), NULL
                    , 0 --InProcess
                    , NULL
                );

            SELECT TOP 1
                   @ETLBatchID = ETLBatchID
            FROM
                   [breeze].[Audit_ExecutionLog]
            ORDER BY
                   ETLBatchID DESC;

            SELECT
                @ETLBatchID AS ETLBatchID;
        END TRY
        BEGIN CATCH
            PRINT 'Error';
        END CATCH;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_ADFProcess_OnEnd]
    @ETLBatchID       INT
    , @status         INT
    , @BatchEnd       DATETIME
    , @SourceCount    INT
    , @StageCount     INT
    , @InsertCount    INT
    , @UpdateCount    INT
    , @UnchangedCount INT
    , @TargetCount    INT
    , @ErrorMessage   VARCHAR(4000)
AS
    BEGIN
        SET NOCOUNT ON;

        UPDATE
            [breeze].[Audit_ExecutionLog]
        SET
            EndTime = GETDATE() --Note: This should NOT be @ProcessDate
            , Status = CASE
                           WHEN ISNULL(Status, 0) = 0
                               THEN
                               @status --Complete
                           ELSE
                               Status
                       END
            , BatchEnd = CONVERT(DATETIME, @BatchEnd)
            , SourceCount = @SourceCount
            , StageCount = @StageCount
            , InsertCount = @InsertCount
            , UpdateCount = @UpdateCount
            , UnchangedCount = @UnchangedCount
            , TargetCount = @TargetCount
            , ErrorMessage = @ErrorMessage
        WHERE
            ETLBatchID = @ETLBatchID;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_AdfStoredProcList_UpdateRunStatus]
    (
        @DWBatchId             INT
        , @LoadType            VARCHAR(20)
        , @StoredProcedureName VARCHAR(100)
        , @RunStatus           VARCHAR(10)
        , @LastAdfRunDate      DATETIME
        , @SystemName          VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ETLBatchID INT;
        DECLARE @status INT;
        DECLARE @SourceCount INT;
        DECLARE @StageCount INT;
        DECLARE @InsertCount INT;
        DECLARE @UpdateCount INT;
        DECLARE @UnchangedCount INT;
        DECLARE @ProcessDate DATETIME;
        DECLARE @Description VARCHAR(50);
        DECLARE @BatchName VARCHAR(50);
        DECLARE @ErrorMessage VARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        DECLARE @TargetCount INT;

        SET @Description = 'Update Stored Procedure run Status';
        SET @BatchName = 'Update Stored Procedure run Status';
        SET @ProcessDate = GETDATE();
        SET @SourceCount = 0;
        SET @StageCount = 0;
        SET @InsertCount = 0;
        SET @UpdateCount = 0;
        SET @UnchangedCount = 0;
        SET @ErrorMessage = '';
        SET @TargetCount = 0;

        EXECUTE [breeze].[usp_Process_OnBegin]
            @DWBatchId
            , @Description
            , @BatchName
            , @ProcessDate
            , NULL
            , NULL
            , @ETLBatchID OUTPUT;


        BEGIN TRY

            UPDATE
                [breeze].[ADFStoredProcList]
            SET
                RunStatus = @RunStatus
                , LastAdfRunDate = @LastAdfRunDate
            WHERE
                SystemName = @SystemName
                AND LoadType = ISNULL(@LoadType, LoadType)
                AND StoredProcedureName = ISNULL(@StoredProcedureName, StoredProcedureName)
                AND IsActive = 1;

            SELECT TOP 1
                   @UpdateCount = row_count
            FROM
                   sys.dm_pdw_request_steps
            WHERE
                   row_count >= 0
                   AND request_id IN
                           (
                               SELECT TOP 1
                                      request_id
                               FROM
                                      sys.dm_pdw_exec_requests
                               WHERE
                                      session_id = SESSION_ID()
                                      AND resource_class IS NOT NULL
                               ORDER BY
                                      end_time DESC
                           );

            --Audit
            EXECUTE [breeze].[usp_Process_OnEnd]
                @ETLBatchID
                , 1
                , @SourceCount
                , @StageCount
                , @InsertCount
                , @UpdateCount
                , @UnchangedCount
                , @TargetCount
                , @ErrorMessage;
        END TRY
        BEGIN CATCH
            --Audit 
            SET @ErrorMessage = SUBSTRING(ERROR_MESSAGE(), 1, 4980);
            SET @ErrorSeverity = ERROR_SEVERITY();
            SET @ErrorState = ERROR_STATE();

            EXECUTE [breeze].[usp_Process_OnEnd]
                @ETLBatchID
                , 2
                , @SourceCount
                , @StageCount
                , @InsertCount
                , @UpdateCount
                , @UnchangedCount
                , @TargetCount
                , @ErrorMessage;

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        END CATCH;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_AdfTableList_UpdateRunStatus]
    (
        @DWBatchId            INT
        , @SourceDBName       VARCHAR(50)
        , @SourceTableName    VARCHAR(100)
        , @AdlsLoadStatus     VARCHAR(10)
        , @AdlsLoadRunDate    DATETIME
        , @StagingLoadStatus  VARCHAR(10)
        , @StagingLoadRunDate DATETIME
        , @SystemName         VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;

        --Audit
        DECLARE @ETLBatchID INT;
        DECLARE @status INT;
        DECLARE @SourceCount INT;
        DECLARE @StageCount INT;
        DECLARE @InsertCount INT;
        DECLARE @UpdateCount INT;
        DECLARE @UnchangedCount INT;
        DECLARE @ProcessDate DATETIME;
        DECLARE @Description VARCHAR(50);
        DECLARE @BatchName VARCHAR(50);
        DECLARE @ErrorMessage VARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        DECLARE @TargetCount INT;

        SET @Description = 'Update table copy run Status';
        SET @BatchName = 'Update table copy run Status';
        SET @ProcessDate = GETDATE();
        SET @SourceCount = 0;
        SET @StageCount = 0;
        SET @InsertCount = 0;
        SET @UpdateCount = 0;
        SET @UnchangedCount = 0;
        SET @ErrorMessage = '';
        SET @TargetCount = 0;

        EXECUTE [breeze].[usp_Process_OnBegin]
            @DWBatchId
            , @Description
            , @BatchName
            , @ProcessDate
            , NULL
            , NULL
            , @ETLBatchID OUTPUT;

        BEGIN TRY

            IF (
                   @AdlsLoadStatus IS NULL
                   AND @StagingLoadStatus IS NULL
               )
                BEGIN
                    UPDATE
                        [breeze].[ADFTableList]
                    SET
                        AdlsLoadStatus = @AdlsLoadStatus
                        , AdlsLoadRunDate = @AdlsLoadRunDate
                        , StagingLoadStatus = @StagingLoadStatus
                        , StagingLoadRunDate = @StagingLoadRunDate
                    WHERE
                        SystemName = @SystemName
                        AND SrcDbOrContainer = ISNULL(@SourceDBName, SrcDbOrContainer)
                        AND SrcObjectName = ISNULL(@SourceTableName, SrcObjectName)
                        AND IsActive = 1;

                    SELECT TOP 1
                           @UpdateCount = row_count
                    FROM
                           sys.dm_pdw_request_steps
                    WHERE
                           row_count >= 0
                           AND request_id IN
                                   (
                                       SELECT TOP 1
                                              request_id
                                       FROM
                                              sys.dm_pdw_exec_requests
                                       WHERE
                                              session_id = SESSION_ID()
                                              AND resource_class IS NOT NULL
                                       ORDER BY
                                              end_time DESC
                                   );
                END;

            ELSE IF (@AdlsLoadStatus IS NOT NULL)
                BEGIN
                    UPDATE
                        [breeze].[ADFTableList]
                    SET
                        AdlsLoadStatus = @AdlsLoadStatus
                        , AdlsLoadRunDate = @AdlsLoadRunDate
                    WHERE
                        SystemName = @SystemName
                        AND SrcDbOrContainer = ISNULL(@SourceDBName, SrcDbOrContainer)
                        AND SrcObjectName = ISNULL(@SourceTableName, SrcObjectName)
                        AND IsActive = 1;

                    SELECT TOP 1
                           @UpdateCount = row_count
                    FROM
                           sys.dm_pdw_request_steps
                    WHERE
                           row_count >= 0
                           AND request_id IN
                                   (
                                       SELECT TOP 1
                                              request_id
                                       FROM
                                              sys.dm_pdw_exec_requests
                                       WHERE
                                              session_id = SESSION_ID()
                                              AND resource_class IS NOT NULL
                                       ORDER BY
                                              end_time DESC
                                   );
                END;

            ELSE IF (@StagingLoadStatus IS NOT NULL)
                BEGIN
                    UPDATE
                        [breeze].[ADFTableList]
                    SET
                        StagingLoadStatus = @StagingLoadStatus
                        , StagingLoadRunDate = @StagingLoadRunDate
                    WHERE
                        SystemName = @SystemName
                        AND SrcDbOrContainer = ISNULL(@SourceDBName, SrcDbOrContainer)
                        AND SrcObjectName = ISNULL(@SourceTableName, SrcObjectName)
                        AND IsActive = 1;

                    SELECT TOP 1
                           @UpdateCount = row_count
                    FROM
                           sys.dm_pdw_request_steps
                    WHERE
                           row_count >= 0
                           AND request_id IN
                                   (
                                       SELECT TOP 1
                                              request_id
                                       FROM
                                              sys.dm_pdw_exec_requests
                                       WHERE
                                              session_id = SESSION_ID()
                                              AND resource_class IS NOT NULL
                                       ORDER BY
                                              end_time DESC
                                   );
                END;

            --Audit
            EXECUTE [breeze].[usp_Process_OnEnd]
                @ETLBatchID
                , 1
                , @SourceCount
                , @StageCount
                , @InsertCount
                , @UpdateCount
                , @UnchangedCount
                , @TargetCount
                , @ErrorMessage;
        END TRY
        BEGIN CATCH
            --Audit 
            SET @ErrorMessage = SUBSTRING(ERROR_MESSAGE(), 1, 4980);
            SET @ErrorSeverity = ERROR_SEVERITY();
            SET @ErrorState = ERROR_STATE();

            EXECUTE [breeze].[usp_Process_OnEnd]
                @ETLBatchID
                , 2
                , @SourceCount
                , @StageCount
                , @InsertCount
                , @UpdateCount
                , @UnchangedCount
                , @TargetCount
                , @ErrorMessage;

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

        END CATCH;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_AdfTablesColumnList_Get]
    (
        @SystemName        VARCHAR(50)
        , @SourceTableName VARCHAR(100)
        , @ETLBatchID      INT
        , @BatchStart      VARCHAR(50)
        , @BatchEnd        VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @DestinationTableName VARCHAR(100);
        DECLARE @LoadType VARCHAR(50);
        DECLARE @QualifiedColumnForFilter VARCHAR(50);
        DECLARE @FilterDefaultValue VARCHAR(50);
        DECLARE @CustomQueryFunction VARCHAR(150);
        DECLARE @Cmd NVARCHAR(150);

        SELECT
            @DestinationTableName = DestObjectName
            , @LoadType = LoadType
            , @QualifiedColumnForFilter = QualifiedColumnForFilter
            , @FilterDefaultValue = CONVERT(VARCHAR(50), FilterDefaultValue, 120)
            , @CustomQueryFunction = CustomQueryFunction
        FROM
            [breeze].[ADFTableList]
        WHERE
            SystemName = @SystemName
            AND SrcObjectName = @SourceTableName;

        IF (@CustomQueryFunction IS NOT NULL)
            BEGIN
                SET @BatchStart
                    = ISNULL(CONVERT(VARCHAR(50), CAST(@BatchStart AS DATETIME), 120), @FilterDefaultValue);
                SET @BatchEnd = CONVERT(NVARCHAR(50), CAST(@BatchEnd AS DATETIME), 120);

                SET @Cmd
                    = N'SELECT ' + @CustomQueryFunction + N'(''' + @BatchStart + N''', ''' + @BatchEnd
                      + N''') AS ColumnList';

                UPDATE
                    [breeze].[Audit_ExecutionLog]
                SET
                    BatchStart = @BatchStart
                    , BatchEnd = @BatchEnd
                WHERE
                    ETLBatchID = @ETLBatchID;

                EXEC sp_executesql
                    @Cmd;
            END;

        ELSE IF (
                    @SystemName = 'breeze'
                    AND @LoadType = 'FULL'
                )
            BEGIN
                SELECT
                        'SELECT '
                        + STUFF(
                              (
                                  SELECT
                                      STRING_AGG(
                                                    CASE
                                                        WHEN DATA_TYPE IN (
                                                                              'time'
                                                                          )
                                                            THEN
                                                            ',CAST([' + meta.COLUMN_NAME + '] AS VARCHAR) ['
                                                            + meta.COLUMN_NAME + ']'
                                                        ELSE
                                                            ',[' + meta.COLUMN_NAME + ']'
                                                    END, ''
                                                )
                                  FROM
                                      INFORMATION_SCHEMA.COLUMNS meta
                                  WHERE
                                      meta.TABLE_NAME = meta1.TABLE_NAME
                                      AND meta.COLUMN_NAME <> 'HashKey'
                              ), 1, 1, ''
                               ) + ' FROM ADFConfigTableList' + @SourceTableName AS ColumnList
                FROM
                        INFORMATION_SCHEMA.COLUMNS meta1
                    INNER JOIN
                        [breeze].[ADFTableList] a
                            ON a.DestObjectName = meta1.TABLE_SCHEMA + '.' + meta1.TABLE_NAME
                WHERE
                        a.DestObjectName = @DestinationTableName
                GROUP BY
                        TABLE_NAME;
            END;

        ELSE IF (
                    @SystemName = 'breeze'
                    AND @LoadType = 'Historical'
                )
            BEGIN
                SELECT
                        'SELECT '
                        + STUFF(
                              (
                                  SELECT
                                      STRING_AGG(
                                                    CASE
                                                        WHEN DATA_TYPE IN (
                                                                              'time'
                                                                          )
                                                            THEN
                                                            ',CAST([' + meta.COLUMN_NAME + '] AS VARCHAR) ['
                                                            + meta.COLUMN_NAME + ']'
                                                        ELSE
                                                            ',[' + meta.COLUMN_NAME + ']'
                                                    END, ''
                                                )
                                  FROM
                                      INFORMATION_SCHEMA.COLUMNS meta
                                  WHERE
                                      meta.TABLE_NAME = meta1.TABLE_NAME
                                      AND meta.COLUMN_NAME <> 'HashKey'
                              ), 1, 1, ''
                               ) + ' FROM ' + @SourceTableName + ' WHERE '
                        + REPLACE(
                                     REPLACE(
                                                STUFF(
                                                    (
                                                        SELECT
                                                            STRING_AGG(
                                                                          ' OR ([' + RTRIM(LTRIM(VALUE)) + '] >= '''
                                                                          + +@FilterDefaultValue + ''')', ''
                                                                      )
                                                        FROM
                                                            STRING_SPLIT(@QualifiedColumnForFilter, ',')
                                                    ), 1, 4, ''
                                                     ), '&gt;', '>'
                                            ), '&lt;', '<'
                                 ) AS ColumnList
                FROM
                        INFORMATION_SCHEMA.COLUMNS meta1
                    INNER JOIN
                        [breeze].[ADFTableList] a
                            ON a.DestObjectName = meta1.TABLE_SCHEMA + '.' + meta1.TABLE_NAME
                WHERE
                        a.DestObjectName = @DestinationTableName
                GROUP BY
                        TABLE_NAME;
            END;

        ELSE IF (
                    @SystemName = 'breeze'
                    AND @LoadType = 'Incremental'
                )
            BEGIN
                SET @BatchStart
                    = ISNULL(CONVERT(VARCHAR(50), CAST(@BatchStart AS DATETIME), 120), @FilterDefaultValue);
                SET @BatchEnd = CONVERT(NVARCHAR(50), CAST(@BatchEnd AS DATETIME), 120);

                UPDATE
                    [breeze].[Audit_ExecutionLog]
                SET
                    BatchStart = @BatchStart
                    , BatchEnd = @BatchEnd
                WHERE
                    ETLBatchID = @ETLBatchID;

                SELECT
                        'SELECT '
                        + STUFF(
                              (
                                  SELECT
                                      STRING_AGG(
                                                    CASE
                                                        WHEN DATA_TYPE IN (
                                                                              'time'
                                                                          )
                                                            THEN
                                                            ',CAST([' + meta.COLUMN_NAME + '] AS VARCHAR) ['
                                                            + meta.COLUMN_NAME + ']'
                                                        ELSE
                                                            ',[' + meta.COLUMN_NAME + ']'
                                                    END, ''
                                                )
                                  FROM
                                      INFORMATION_SCHEMA.COLUMNS meta
                                  WHERE
                                      meta.TABLE_NAME = meta1.TABLE_NAME
                                      AND meta.COLUMN_NAME <> 'HashKey'
                              ), 1, 1, ''
                               ) + ' FROM ' + @SourceTableName + ' WHERE '
                        + REPLACE(
                                     REPLACE(
                                                STUFF(
                                                    (
                                                        SELECT
                                                            STRING_AGG(
                                                                          ' OR ([' + RTRIM(LTRIM(VALUE)) + '] >= '''
                                                                          + +@BatchStart + ''' AND [' + RTRIM(LTRIM(VALUE))
                                                                          + '] < ''' + @BatchEnd + ''')', ''
                                                                      )
                                                        FROM
                                                            STRING_SPLIT(@QualifiedColumnForFilter, ',')
                                                    ), 1, 4, ''
                                                     ), '&gt;', '>'
                                            ), '&lt;', '<'
                                 ) AS ColumnList
                FROM
                        INFORMATION_SCHEMA.COLUMNS meta1
                    INNER JOIN
                        [breeze].[ADFTableList] a
                            ON a.DestObjectName = meta1.TABLE_SCHEMA + '.' + meta1.TABLE_NAME
                WHERE
                        a.DestObjectName = @DestinationTableName
                GROUP BY
                        TABLE_NAME;
            END;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO



SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_DeleteAuditData] @DWBatchId INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @NumberOfDays INT;

        SELECT
            @NumberOfDays = Value
        FROM
            [breeze].[Audit_ConfigMaster]
        WHERE
            UPPER(Type) = UPPER('AuditNumberOfDays');

        --SELECT @NumberOfDays
        DELETE
        --select * 
        FROM
        [breeze].[Audit_ExecutionTracking]
        WHERE
            DATEDIFF(DAY, [StageTimestamp], GETDATE()) > ISNULL(@NumberOfDays, 7);
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_DWBatch_OnBegin]
    @DWBatchId    INT OUTPUT
    , @AdlsLoad   BIT
    , @StageLoad  BIT
    , @DWLoad     BIT
    , @ReportLoad BIT
    , @DWState    VARCHAR(10)
    , @SystemName VARCHAR(20)
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @DWBatchStartDateTime DATETIME;

        BEGIN TRY
            SET @DWBatchStartDateTime = GETDATE();

            --Insert the log record
            INSERT INTO [breeze].[DWBatch]
                (
                    DWBatchStartDateTime
                    , DWBatchStatus
                    , DWAdlsLoad
                    , DWStageLoad
                    , DWLoad
                    , DWReportLoad
                    , SystemName
                    , DWState
                )
            VALUES
                (
                    @DWBatchStartDateTime, 0 --InProcess
                    , @AdlsLoad, @StageLoad, @DWLoad, @ReportLoad, @SystemName, @DWState
                );

            SELECT TOP 1
                   @DWBatchId = DWBatchId
            FROM
                   [breeze].DWBatch
            ORDER BY
                   DWBatchId DESC;

            SELECT
                @DWBatchId AS DWBatchId
                , @DWLoad AS DWState;
        END TRY
        BEGIN CATCH
            PRINT 'Error';
        END CATCH;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_DWBatch_OnEnd]
    @DWBatchId    INT
    , @status     INT
    , @AdlsLoad   BIT
    , @StageLoad  BIT
    , @DWLoad     BIT
    , @ReportLoad BIT
    , @DWState    VARCHAR(10)
    , @SystemName VARCHAR(20)
AS
    BEGIN
        SET NOCOUNT ON;

        -- Updating for all successful completion (after reports completion)

        IF @DWState = 'complete'
           AND @status = 1
            BEGIN
                UPDATE
                    [breeze].[DWBatch]
                SET
                    DWAdlsLoad = 0
                    , DWLoad = 0
                    , DWReportLoad = 0
                    , DWStageLoad = 0
                    , DWState = @DWState
                    , DWBatchStatus = @status
                    , DWBatchEndDateTime = GETDATE()
                WHERE
                    DWBatchId = @DWBatchId;
            END;

        -- Updating the DW table after successfull ADLS load

        ELSE IF @DWState = 'stage'
                AND @status = 1
            BEGIN
                UPDATE
                    [breeze].[DWBatch]
                SET
                    DWAdlsLoad = 0
                    , DWState = @DWState
                WHERE
                    DWBatchId = @DWBatchId;
            END;

        -- Updating the DW table after succesfull Stage load

        ELSE IF @DWState = 'dw'
                AND @status = 1
            BEGIN
                UPDATE
                    [breeze].[DWBatch]
                SET
                    DWAdlsLoad = 0
                    , DWStageLoad = 0
                    , DWState = @DWState
                WHERE
                    DWBatchId = @DWBatchId;
            END;

        -- Updating the DW table after succesfull DW load

        ELSE IF @DWState = 'report'
                AND @status = 1
            BEGIN
                UPDATE
                    [breeze].[DWBatch]
                SET
                    DWAdlsLoad = 0
                    , DWStageLoad = 0
                    , DWLoad = 0
                    , DWState = @DWState
                WHERE
                    DWBatchId = @DWBatchId;
            END;

        SET NOCOUNT OFF;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_Get_ADFProcList]
    @SourceSystem NVARCHAR(500)
    , @LoadType   NVARCHAR(500)
    , @ExecOrder  NVARCHAR(500)
    , @ProcList   NVARCHAR(500)
    , @RunType    NVARCHAR(500)
    , @GetWhat    NVARCHAR(500)
-- @SourceSystem NVARCHAR(500) = 'all'
-- , @LoadType   NVARCHAR(500) = 'all'
-- , @ExecOrder  NVARCHAR(500) = 'all'
-- , @ProcList   NVARCHAR(500) = 'all'
-- , @RunType    NVARCHAR(500) = 'new' --new-execute all without looking at RunStatus, rerun-execute only pending or failed ones
-- , @GetWhat    NVARCHAR(500) = 'proclist'
--proclist-output will be relevant list of procs, execorder-output will be only unique exec order values
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @Cmd NVARCHAR(1000);

        IF LOWER(@GetWhat) = 'proclist'
            SET @Cmd = N'SELECT * FROM breeze.ADFStoredProcList WHERE IsActive = 1 ';
        ELSE IF LOWER(@GetWhat) = 'execorder'
            SET @Cmd = N'SELECT DISTINCT ExecOrder FROM breeze.ADFStoredProcList WHERE IsActive = 1 ';

        IF LOWER(@RunType) = 'rerun'
            BEGIN
                SET @Cmd = @Cmd + N' AND ISNULL(RunStatus, ''Failed'') = ''Failed'' ';
            END;

        IF LOWER(@SourceSystem) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND LOWER(SystemName) = LOWER(''' + @SourceSystem + N''') ';
            END;

        IF LOWER(@LoadType) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND LOWER(LoadType) = LOWER(''' + @LoadType + N''') ';
            END;

        IF LOWER(@ExecOrder) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND LOWER(ExecOrder) = LOWER(''' + @ExecOrder + N''') ';
            END;

        IF LOWER(@ProcList) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND ADFStoredProcListId IN (' + @ProcList + N') ';
            END;

        EXEC sp_executesql
            @Cmd;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_Get_ADFTableList]
    @SourceSystem   NVARCHAR(500)
    , @SourceDB     NVARCHAR(500)
    , @SourceTables NVARCHAR(500)
    , @ProcessStep  NVARCHAR(500)
    , @RunType      NVARCHAR(500)
-- 	@SourceSystem NVARCHAR(500) = 'all'
--   , @SourceDB NVARCHAR(500) = 'all'
--   , @SourceTables NVARCHAR(500) = 'all'
--   , @ProcessStep NVARCHAR(500) = 'source2adls'
--   , @RunType NVARCHAR(500) = 'new'
--new-execute all without looking at RunStatus, rerun-execute only pending or failed ones
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @Cmd NVARCHAR(1000);

        SET @Cmd = N'SELECT * FROM [breeze].[ADFTableList] WHERE IsActive = 1 ';

        IF LOWER(@ProcessStep) = 'source2adls'
            BEGIN
                SET @Cmd = @Cmd + N' AND Source = ''SQLDB'' AND Destination = ''ADLS'' ';
            END;
        ELSE IF LOWER(@ProcessStep) = 'adls2stage'
            BEGIN
                SET @Cmd = @Cmd + N' AND Source = ''ADLS'' ';
                IF LOWER(@RunType) = 'rerun'
                    SET @Cmd = @Cmd + N' AND ISNULL(StagingLoadStatus, ''Failed'') = ''Failed'' ';
            END;
        ELSE IF LOWER(@RunType) = 'rerun'
            SET @Cmd = @Cmd + N' AND ISNULL(AdlsLoadStatus, ''Failed'') = ''Failed'' ';


        IF LOWER(@SourceSystem) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND LOWER(SystemName) = LOWER(''' + @SourceSystem + N''') ';
            END;

        IF LOWER(@SourceDB) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND LOWER(SourceDBName) = LOWER(''' + @SourceDB + N''') ';
            END;

        IF LOWER(@SourceTables) <> 'all'
            BEGIN
                SET @Cmd = @Cmd + N' AND ADFTableListId IN (' + @SourceTables + N') ';
            END;

        --select @Cmd
        EXEC sp_executesql
            @Cmd;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_Process_OnBegin]
    @DWBatchId     INT
    , @Description VARCHAR(100)
    , @BatchName   VARCHAR(50)
    , @ProcessDate DATETIME
    , @operator    VARCHAR(30)
    , @StartTime   DATETIME
    , @ETLBatchID  INT OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY

            --Declare @ETLBatchID INT
            --Coalesce @ProcessDate
            SET @ProcessDate = ISNULL(@ProcessDate, GETDATE());
            --Coalesce @operator
            SET @operator = NULLIF(LTRIM(RTRIM(@operator)), '');
            SET @operator = ISNULL(@operator, SUSER_SNAME());
            SET @StartTime = GETDATE();


            --Insert the log record
            INSERT INTO [breeze].[Audit_ExecutionLog]
                (
                    DWBatchId
                    , [Description]
                    , [BatchName]
                    , [ProcessDate]
                    , [Operator]
                    , [StartTime]
                    , [EndTime]
                    , [Status]
                    , [ErrorMessage]
                )
            VALUES
                (
                    @DWBatchId, @Description, @BatchName, @ProcessDate, @operator, GETDATE(), NULL, 0 --InProcess
                    , NULL
                );

            SELECT TOP 1
                   @ETLBatchID = ETLBatchID
            FROM
                   Audit_ExecutionLog
            WHERE
                   StartTime = @StartTime
                   AND [Description] = @Description
                   AND BatchName = @BatchName
                   AND ProcessDate = @ProcessDate
                   AND Operator = @operator

            SELECT
                @ETLBatchID AS ETLBatchID;
        END TRY
        BEGIN CATCH
            PRINT 'Error';
        END CATCH;
    END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [breeze].[usp_Process_OnEnd]
    @ETLBatchID       INT
    , @status         INT
    , @SourceCount    INT
    , @StageCount     INT
    , @InsertCount    INT
    , @UpdateCount    INT
    , @UnchangedCount INT
    , @TargetCount    INT
    , @ErrorMessage   VARCHAR(4000)
AS
    BEGIN
        SET NOCOUNT ON;

        UPDATE
            [breeze].[Audit_ExecutionLog]
        SET
            EndTime = GETDATE() --Note: This should NOT be @ProcessDate
            , Status = CASE
                           WHEN ISNULL(Status, 0) = 0
                               THEN
                               @status --Complete
                           ELSE
                               Status
                       END
            , SourceCount = @SourceCount
            , StageCount = @StageCount
            , InsertCount = @InsertCount
            , UpdateCount = @UpdateCount
            , UnchangedCount = @UnchangedCount
            , TargetCount = @TargetCount
            , ErrorMessage = @ErrorMessage
        WHERE
            ETLBatchID = @ETLBatchID;
    END;
GO
