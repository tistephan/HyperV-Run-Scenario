USE [master]
GO
/****** Object:  Database [Artifacts]    Script Date: 11.09.2021 00:44:26 ******/
CREATE DATABASE [Artifacts]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Artifacts', FILENAME = N'D:\MSSQL\Artifacts.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Artifacts_log', FILENAME = N'D:\MSSQL\Artifacts_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Artifacts] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Artifacts].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Artifacts] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Artifacts] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Artifacts] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Artifacts] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Artifacts] SET ARITHABORT OFF 
GO
ALTER DATABASE [Artifacts] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Artifacts] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Artifacts] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Artifacts] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Artifacts] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Artifacts] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Artifacts] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Artifacts] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Artifacts] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Artifacts] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Artifacts] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Artifacts] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Artifacts] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Artifacts] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Artifacts] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Artifacts] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Artifacts] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Artifacts] SET RECOVERY FULL 
GO
ALTER DATABASE [Artifacts] SET  MULTI_USER 
GO
ALTER DATABASE [Artifacts] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Artifacts] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Artifacts] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Artifacts] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Artifacts] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Artifacts] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Artifacts', N'ON'
GO
ALTER DATABASE [Artifacts] SET QUERY_STORE = OFF
GO
USE [Artifacts]
GO
/****** Object:  Table [dbo].[Action]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Action](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NOT NULL,
 CONSTRAINT [PK_Action_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Device_Type]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Device_Type](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Device_Type] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Eventlog]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Eventlog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[EventLog] [varchar](255) NULL,
	[RecordNumber] [int] NULL,
	[TimeGenerated] [datetime] NULL,
	[TimeWritten] [datetime] NULL,
	[EventID] [int] NULL,
	[EventType] [int] NULL,
	[EventTypeName] [varchar](255) NULL,
	[EventCategory] [int] NULL,
	[EventCategoryName] [varchar](255) NULL,
	[SourceName] [varchar](255) NULL,
	[Strings] [varchar](255) NULL,
	[ComputerName] [varchar](255) NULL,
	[SID] [varchar](255) NULL,
	[Message] [varchar](255) NULL,
	[Data] [varchar](255) NULL,
 CONSTRAINT [PK_Eventlog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[File_Hashes]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[File_Hashes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[Filename] [varchar](255) NOT NULL,
	[Path] [varchar](255) NOT NULL,
	[Timestamp_Created] [datetime] NOT NULL,
	[Timestamp_Changed] [datetime] NOT NULL,
	[Timestamp_LastAccess] [datetime] NOT NULL,
	[Fileversion] [varchar](255) NULL,
	[MD5_Checksum] [varchar](32) NOT NULL,
	[SHA1_Checksum] [varchar](40) NOT NULL,
 CONSTRAINT [PK_File_Hashes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MainScenario]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MainScenario](
	[ID] [int] IDENTITY(0,1) NOT NULL,
	[Scenario_Template_ID] [int] NOT NULL,
	[W10_Version_ID] [int] NOT NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
 CONSTRAINT [PK_Scenario] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prefetch_File]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prefetch_File](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[Prefetch_Filename] [varchar](255) NOT NULL,
	[Referenced_Filename] [varchar](255) NOT NULL,
	[Path] [varchar](255) NOT NULL,
	[Device_Path] [varchar](255) NOT NULL,
	[Index] [int] NOT NULL,
 CONSTRAINT [PK_Prefetch_File] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProcessMonitor]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProcessMonitor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[Time of Day] [nvarchar](max) NULL,
	[Process Name] [nvarchar](max) NULL,
	[PID] [nvarchar](max) NULL,
	[Operation] [nvarchar](max) NULL,
	[Path] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Detail] [nvarchar](max) NULL,
	[TID] [nvarchar](max) NULL,
	[Date & Time] [nvarchar](max) NULL,
	[Image Path] [nvarchar](max) NULL,
	[Command Line] [nvarchar](max) NULL,
	[Version] [nvarchar](max) NULL,
	[User] [nvarchar](max) NULL,
	[Session] [nvarchar](max) NULL,
	[Parent PID] [nvarchar](max) NULL,
 CONSTRAINT [PK_ProcessMonitor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RecoveryKey]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecoveryKey](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[OS_KeyProtectorID] [varchar](36) NULL,
	[OS_RecoveryKey] [varchar](56) NULL,
	[BasicDisk_KeyProtectorID] [varchar](36) NULL,
	[BasicDisk_RecoveryKey] [varchar](56) NULL,
 CONSTRAINT [PK_RecoveryKey] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Registry]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Registry](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Scenario_ID] [int] NOT NULL,
	[Key] [varchar](max) NOT NULL,
	[Name] [varchar](max) NOT NULL,
	[Value] [varchar](max) NULL,
 CONSTRAINT [PK_Registry] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Scenario_Template]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Scenario_Template](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action_ID] [int] NOT NULL,
	[Device_Type_ID] [int] NOT NULL,
 CONSTRAINT [PK_Scenario_Template] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_Eventlog]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_Eventlog](
	[EventLog] [varchar](255) NULL,
	[RecordNumber] [int] NULL,
	[TimeGenerated] [datetime] NULL,
	[TimeWritten] [datetime] NULL,
	[EventID] [int] NULL,
	[EventType] [int] NULL,
	[EventTypeName] [varchar](255) NULL,
	[EventCategory] [int] NULL,
	[EventCategoryName] [varchar](255) NULL,
	[SourceName] [varchar](255) NULL,
	[Strings] [varchar](255) NULL,
	[ComputerName] [varchar](255) NULL,
	[SID] [varchar](255) NULL,
	[Message] [varchar](255) NULL,
	[Data] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_File_Hashes]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_File_Hashes](
	[Filename] [varchar](255) NOT NULL,
	[Path] [varchar](255) NOT NULL,
	[Timestamp_Created] [datetime] NOT NULL,
	[Timestamp_Changed] [datetime] NOT NULL,
	[Timestamp_LastAccess] [datetime] NOT NULL,
	[Fileversion] [varchar](255) NULL,
	[MD5_Checksum] [varchar](32) NOT NULL,
	[SHA1_Checksum] [varchar](40) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_Prefetch_File]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_Prefetch_File](
	[Prefetch_Filename] [varchar](255) NOT NULL,
	[Referenced_Filename] [varchar](255) NOT NULL,
	[Path] [varchar](255) NOT NULL,
	[Device_Path] [varchar](255) NOT NULL,
	[Index] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_ProcessMonitor]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_ProcessMonitor](
	[Time of Day] [nvarchar](max) NULL,
	[Process Name] [nvarchar](max) NULL,
	[PID] [nvarchar](max) NULL,
	[Operation] [nvarchar](max) NULL,
	[Path] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Detail] [nvarchar](max) NULL,
	[TID] [nvarchar](max) NULL,
	[Date & Time] [nvarchar](max) NULL,
	[Image Path] [nvarchar](max) NULL,
	[Command Line] [nvarchar](max) NULL,
	[Version] [nvarchar](max) NULL,
	[User] [nvarchar](max) NULL,
	[Session] [nvarchar](max) NULL,
	[Parent PID] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_RecoveryKey]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_RecoveryKey](
	[OS_KeyProtectorID] [varchar](36) NULL,
	[OS_RecoveryKey] [varchar](56) NULL,
	[BasicDisk_KeyProtectorID] [varchar](36) NULL,
	[BasicDisk_RecoveryKey] [varchar](56) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[temp_Registry]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_Registry](
	[Key] [varchar](max) NOT NULL,
	[Name] [varchar](max) NOT NULL,
	[Value] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[W10_Version]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[W10_Version](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Version] [varchar](4) NOT NULL,
 CONSTRAINT [PK_W10_Version] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Action] ON 
GO
INSERT [dbo].[Action] ([ID], [Title]) VALUES (1, N'Verschlüsseln')
GO
INSERT [dbo].[Action] ([ID], [Title]) VALUES (2, N'Pausieren')
GO
SET IDENTITY_INSERT [dbo].[Action] OFF
GO
SET IDENTITY_INSERT [dbo].[Device_Type] ON 
GO
INSERT [dbo].[Device_Type] ([ID], [Title]) VALUES (1, N'Betriebssystem')
GO
INSERT [dbo].[Device_Type] ([ID], [Title]) VALUES (2, N'Wechseldatenträger')
GO
SET IDENTITY_INSERT [dbo].[Device_Type] OFF
GO
SET IDENTITY_INSERT [dbo].[MainScenario] ON 
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (1, 1, 1, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (2, 2, 1, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (3, 3, 1, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (4, 4, 1, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (5, 1, 2, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (6, 2, 2, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (7, 3, 2, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (8, 4, 2, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (9, 1, 3, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (10, 2, 3, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (11, 3, 3, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (12, 4, 3, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (13, 1, 4, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (14, 2, 4, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (15, 3, 4, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (16, 4, 4, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (17, 1, 5, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (18, 2, 5, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (19, 3, 5, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (20, 4, 5, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (21, 1, 6, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (22, 2, 6, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (23, 3, 6, NULL, NULL)
GO
INSERT [dbo].[MainScenario] ([ID], [Scenario_Template_ID], [W10_Version_ID], [StartTime], [EndTime]) VALUES (24, 4, 6, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[MainScenario] OFF
GO
SET IDENTITY_INSERT [dbo].[Scenario_Template] ON 
GO
INSERT [dbo].[Scenario_Template] ([ID], [Action_ID], [Device_Type_ID]) VALUES (1, 1, 1)
GO
INSERT [dbo].[Scenario_Template] ([ID], [Action_ID], [Device_Type_ID]) VALUES (2, 2, 1)
GO
INSERT [dbo].[Scenario_Template] ([ID], [Action_ID], [Device_Type_ID]) VALUES (3, 1, 2)
GO
INSERT [dbo].[Scenario_Template] ([ID], [Action_ID], [Device_Type_ID]) VALUES (4, 2, 2)
GO
SET IDENTITY_INSERT [dbo].[Scenario_Template] OFF
GO
SET IDENTITY_INSERT [dbo].[W10_Version] ON 
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (1, N'1507')
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (2, N'1903')
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (3, N'1909')
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (4, N'2004')
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (5, N'20H2')
GO
INSERT [dbo].[W10_Version] ([ID], [Version]) VALUES (6, N'21H1')
GO
SET IDENTITY_INSERT [dbo].[W10_Version] OFF
GO
ALTER TABLE [dbo].[Eventlog]  WITH CHECK ADD  CONSTRAINT [FK_Eventlog_MainScenario] FOREIGN KEY([Scenario_ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[Eventlog] CHECK CONSTRAINT [FK_Eventlog_MainScenario]
GO
ALTER TABLE [dbo].[File_Hashes]  WITH CHECK ADD  CONSTRAINT [FK_File_Hashes_MainScenario] FOREIGN KEY([Scenario_ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[File_Hashes] CHECK CONSTRAINT [FK_File_Hashes_MainScenario]
GO
ALTER TABLE [dbo].[MainScenario]  WITH CHECK ADD  CONSTRAINT [FK_MainScenario_Scenario_Template] FOREIGN KEY([Scenario_Template_ID])
REFERENCES [dbo].[Scenario_Template] ([ID])
GO
ALTER TABLE [dbo].[MainScenario] CHECK CONSTRAINT [FK_MainScenario_Scenario_Template]
GO
ALTER TABLE [dbo].[MainScenario]  WITH CHECK ADD  CONSTRAINT [FK_Scenario_W10_Version] FOREIGN KEY([W10_Version_ID])
REFERENCES [dbo].[W10_Version] ([ID])
GO
ALTER TABLE [dbo].[MainScenario] CHECK CONSTRAINT [FK_Scenario_W10_Version]
GO
ALTER TABLE [dbo].[Prefetch_File]  WITH CHECK ADD  CONSTRAINT [FK_Prefetch_File_MainScenario] FOREIGN KEY([Scenario_ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[Prefetch_File] CHECK CONSTRAINT [FK_Prefetch_File_MainScenario]
GO
ALTER TABLE [dbo].[ProcessMonitor]  WITH CHECK ADD  CONSTRAINT [FK_ProcessMonitor_MainScenario] FOREIGN KEY([Scenario_ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[ProcessMonitor] CHECK CONSTRAINT [FK_ProcessMonitor_MainScenario]
GO
ALTER TABLE [dbo].[RecoveryKey]  WITH CHECK ADD  CONSTRAINT [FK_RecoveryKey_MainScenario] FOREIGN KEY([ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[RecoveryKey] CHECK CONSTRAINT [FK_RecoveryKey_MainScenario]
GO
ALTER TABLE [dbo].[Registry]  WITH CHECK ADD  CONSTRAINT [FK_Registry_MainScenario] FOREIGN KEY([Scenario_ID])
REFERENCES [dbo].[MainScenario] ([ID])
GO
ALTER TABLE [dbo].[Registry] CHECK CONSTRAINT [FK_Registry_MainScenario]
GO
ALTER TABLE [dbo].[Scenario_Template]  WITH CHECK ADD  CONSTRAINT [FK_Scenario_Template_Action] FOREIGN KEY([Action_ID])
REFERENCES [dbo].[Action] ([ID])
GO
ALTER TABLE [dbo].[Scenario_Template] CHECK CONSTRAINT [FK_Scenario_Template_Action]
GO
ALTER TABLE [dbo].[Scenario_Template]  WITH CHECK ADD  CONSTRAINT [FK_Scenario_Template_Device_Type] FOREIGN KEY([Device_Type_ID])
REFERENCES [dbo].[Device_Type] ([ID])
GO
ALTER TABLE [dbo].[Scenario_Template] CHECK CONSTRAINT [FK_Scenario_Template_Device_Type]
GO
/****** Object:  StoredProcedure [dbo].[CleanUpTables]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CleanUpTables] 
AS
BEGIN
	DELETE FROM Eventlog
	DELETE FROM File_Hashes
	DELETE FROM ProcessMonitor
	DELETE FROM Prefetch_File
	DELETE FROM Registry
	DELETE FROM RecoveryKey
	
	DELETE FROM temp_Eventlog
	DELETE FROM temp_File_Hashes
	DELETE FROM temp_ProcessMonitor
	DELETE FROM temp_Prefetch_File
	DELETE FROM temp_Registry
	DELETE FROM temp_RecoveryKey
	
	UPDATE MainScenario SET StartTime=NULL,EndTime=NULL

	DBCC CHECKIDENT ('Action', RESEED, 0)
	DBCC CHECKIDENT ('Eventlog', RESEED, 0)
	DBCC CHECKIDENT ('File_Hashes', RESEED, 0)
	DBCC CHECKIDENT ('MainScenario', RESEED, 0)
	DBCC CHECKIDENT ('Prefetch_File', RESEED, 0)
	DBCC CHECKIDENT ('ProcessMonitor', RESEED, 0)
	DBCC CHECKIDENT ('RecoveryKey', RESEED, 0)
	DBCC CHECKIDENT ('Registry', RESEED, 0)
	DBCC CHECKIDENT ('Scenario_Template', RESEED, 0)


END
GO
/****** Object:  StoredProcedure [dbo].[convertTempTables]    Script Date: 11.09.2021 00:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[convertTempTables] @scenario_id INT
--CREATE PROCEDURE [dbo].[convertTempTables] @scenario_id INT
AS
	INSERT INTO dbo.Eventlog
		(Scenario_ID,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data)
	SELECT
		@scenario_id,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data
	FROM temp_Eventlog

	INSERT INTO dbo.Eventlog
		(Scenario_ID,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data)
	SELECT
		@scenario_id,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data
	FROM temp_Eventlog

	INSERT INTO dbo.Eventlog
		(Scenario_ID,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data)
	SELECT
		@scenario_id,EventLog,RecordNumber,TimeGenerated,TimeWritten,EventID,EventType,EventTypeName,EventCategory,EventCategoryName,SourceName,Strings,ComputerName,SID,Message,Data
	FROM temp_Eventlog

	-- Protokolldaten in Tabelle ProcessMonitor weiter eingrenzen, da Process Monitor-Filter nicht alle Angaben entfernt
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\Tcpip%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%pnputil.exe%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$Mft%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$EXTEND%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$Secure:$SDS:$DATA%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Recovery\WindowsRE%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Windows\INF%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\System Volume Information%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\Windows\System32\CatRoot%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%\$LogFile%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SYSTEM\DriverDatabase%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCR\Interface%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCU\Console%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKCU\System\GameConfigStore%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DeviceDisplayObjects%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\DeviceClasses%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\DeviceContainers%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Control\Terminal Server%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\DeviceInstall%'
	DELETE FROM temp_ProcessMonitor WHERE [Path] LIKE '%HKLM\System\CurrentControlSet\Services\Tcpip%'
	DELETE FROM temp_ProcessMonitor WHERE [PATH] LIKE '%procmon%'
	DELETE FROM temp_ProcessMonitor WHERE [Command Line] LIKE 'MsMpEng.exe'
	DELETE FROM temp_ProcessMonitor WHERE [Path] IN ('HKLM\System\CurrentControlSet\Control','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Management Infrastructure\ErrorResources','HKLM\Software\Microsoft\Windows\CurrentVersion\SideBySide\Winners','HKLM\System\CurrentControlSet\Control\Session Manager\Environment','HKCU\Control Panel\International','HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers','HKLM\System\CurrentControlSet\Control','HKCU','HKCR','HKLM','HKLM\SOFTWARE','C:\Windows\ServiceProfiles\NetworkService','HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion','HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR')

	INSERT INTO dbo.ProcessMonitor
		(Scenario_ID,[Time of Day],[Process Name],PID,Operation,[Path],Result,Detail,TID,[Date & Time],[Image Path],[Command Line],[Version],[User],[Session],[Parent PID])
	SELECT
		@scenario_id,[Time of Day],[Process Name],PID,Operation,[Path],Result,Detail,TID,[Date & Time],[Image Path],[Command Line],[Version],[User],[Session],[Parent PID]
	FROM temp_ProcessMonitor
	ORDER BY [Time of Day]

	
	-- Sonderzeichen in Tabelle ProcessMonitor ersetzen
	UPDATE 
	    ProcessMonitor
	SET
		[Command Line] = REPLACE([Command Line],'[semicolon]',';'),
		Detail = REPLACE(Detail,'[semicolon]',';'),
		Operation = REPLACE(Operation,'[semicolon]',';'),
		[Path] = REPLACE([Path],'[semicolon]',';')		
	WHERE
		Operation LIKE '%[semicolon]%'
	   
	INSERT INTO dbo.Prefetch_File
		(Scenario_ID,Prefetch_Filename,Referenced_Filename,Path,Device_Path,[Index])
	SELECT
		@scenario_id,Prefetch_Filename,Referenced_Filename,Path,Device_Path,[Index]
	FROM temp_Prefetch_File

	INSERT INTO dbo.Registry
		(Scenario_ID,[Key],[Name],[Value])
	SELECT
		@scenario_id,[Key],[Name],[Value]
	FROM temp_Registry

	INSERT INTO dbo.File_Hashes
		(Scenario_ID,Filename,Path,Timestamp_Created,Timestamp_Changed,Timestamp_LastAccess,Fileversion,MD5_Checksum,SHA1_Checksum)
	SELECT
		@scenario_id,Filename,Path,Timestamp_Created,Timestamp_Changed,Timestamp_LastAccess,Fileversion,MD5_Checksum,SHA1_Checksum
	FROM temp_File_Hashes

	IF EXISTS(SELECT * FROM RecoveryKey WHERE Scenario_id=@scenario_id)
		UPDATE RecoveryKey
		SET
			RecoveryKey.OS_KeyProtectorID=CASE WHEN RecoveryKey.OS_KeyProtectorID IS NULL THEN (SELECT OS_KeyProtectorID FROM temp_RecoveryKey) ELSE (SELECT OS_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.OS_RecoveryKey=CASE WHEN RecoveryKey.OS_RecoveryKey IS NULL THEN (SELECT OS_RecoveryKey FROM temp_RecoveryKey) ELSE (SELECT OS_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.BasicDisk_KeyProtectorID=CASE WHEN RecoveryKey.BasicDisk_KeyProtectorID IS NULL THEN (SELECT BasicDisk_KeyProtectorID FROM temp_RecoveryKey) ELSE (SELECT BasicDisk_KeyProtectorID FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END,
			RecoveryKey.BasicDisk_RecoveryKey=CASE WHEN RecoveryKey.BasicDisk_RecoveryKey IS NULL THEN (SELECT BasicDisk_RecoveryKey FROM temp_RecoveryKey) ELSE (SELECT BasicDisk_RecoveryKey FROM RecoveryKey WHERE Scenario_ID=@scenario_id) END
		WHERE RecoveryKey.Scenario_ID=@scenario_id
	ELSE
		INSERT INTO dbo.RecoveryKey
			(Scenario_ID,OS_KeyProtectorID,OS_RecoveryKey,BasicDisk_KeyProtectorID,BasicDisk_RecoveryKey)
		SELECT
			@scenario_id,OS_KeyProtectorID,OS_RecoveryKey,BasicDisk_KeyProtectorID,BasicDisk_RecoveryKey
		FROM temp_RecoveryKey

	-- Temporäre Tabellen leeren
	DELETE FROM temp_Eventlog
	DELETE FROM temp_ProcessMonitor
	DELETE FROM temp_Prefetch_File
	DELETE FROM temp_File_Hashes
	DELETE FROM temp_Registry
	DELETE FROM temp_RecoveryKey

GO
USE [master]
GO
ALTER DATABASE [Artifacts] SET  READ_WRITE 
GO
