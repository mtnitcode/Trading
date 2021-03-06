USE [Trading]
GO
/****** Object:  UserDefinedFunction [dbo].[GregorianToPersian]    Script Date: 9/7/2020 8:15:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[GregorianToPersian]
(
@Date varchar(10)
)
RETURNS varchar(10)
AS
BEGIN    DECLARE @ResultVar varchar(10)
declare @Year int
declare @Month int
declare @Day int
declare @PersianYear int
declare @PersianMonth int
declare @PersianDay int
declare @StartMonthGregorianDateInPersianCalendar int=10
declare @StartDayGregorianDateInPersianCalendar int=11

set @Year=convert(int,substring(@Date,1,4))
set @Month=convert(int,substring(@Date,6,2))
set @Day=convert(int,substring(@Date,9,2))
declare @GregorianDayIndex int=0

if(dbo.IsLeapYear(@Year)=1)
set @StartDayGregorianDateInPersianCalendar=11
else
if(dbo.IsLeapYear(@Year-1)=1)
set @StartDayGregorianDateInPersianCalendar=12
else
set @StartDayGregorianDateInPersianCalendar=11
declare @m_index int=1
while @m_index<=@Month-1
begin
set @GregorianDayIndex=@GregorianDayIndex+dbo.NumberOfDaysInMonthGregorian(@Year,@m_index)
set @m_index=@m_index+1
end
set @GregorianDayIndex=@GregorianDayIndex+@Day

if(@GregorianDayIndex>=80)
begin
set @PersianYear=@Year-621
end
else
begin
set @PersianYear=@Year-622
end

declare @mdays int
declare @m int
declare @index int=@GregorianDayIndex
set @m_index=0
while 1=1
begin
if(@m_index<=2)
set @m=@StartMonthGregorianDateInPersianCalendar+@m_index
else
set @m=@m_index-2

set @mdays=dbo.NumberOfDayInMonthPersian(@Year,@m)
if(@m=@StartMonthGregorianDateInPersianCalendar)
set @mdays=@mdays-@StartDayGregorianDateInPersianCalendar+1

if(@index<=@mdays)
begin
set @PersianMonth=@m
if(@m=@StartMonthGregorianDateInPersianCalendar)
set @PersianDay=@index+@StartDayGregorianDateInPersianCalendar-1
else
set @PersianDay=@index
break
end
else
begin
set @index=@index-@mdays
set @m_index=@m_index+1
end
end

set @ResultVar=
convert(varchar(4),@PersianYear)+'-'+
right('0'+convert(varchar(2),@PersianMonth),2)+'-'+
right('0'+convert(varchar(2),@PersianDay),2)


RETURN @ResultVar

END
GO
/****** Object:  UserDefinedFunction [dbo].[IsLeapYear]    Script Date: 9/7/2020 8:15:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[IsLeapYear]
(
@Year int
)
RETURNS bit
AS
BEGIN
DECLARE @ResultVar bit

if @Year % 400 = 0
Begin
set @ResultVar=1
end
else if @Year % 100 = 0
Begin
set @ResultVar=0
end
else if @Year % 4 = 0
Begin
set @ResultVar=1
end
else
Begin
set @ResultVar=0
end

RETURN @ResultVar

END

GO
/****** Object:  UserDefinedFunction [dbo].[NumberOfDayInMonthPersian]    Script Date: 9/7/2020 8:15:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[NumberOfDayInMonthPersian]
(
@Year int,
@Month int
)
RETURNS int
AS
BEGIN

DECLARE @ResultVar int
if(@Month<=6)
set @ResultVar=31
else
if(@Month=12)
if(dbo.IsLeapYear(@Year-1)=1)
set @ResultVar=30
else
set @ResultVar=29
else
set @ResultVar=30

RETURN @ResultVar

END
GO
/****** Object:  UserDefinedFunction [dbo].[NumberOfDaysInMonthGregorian]    Script Date: 9/7/2020 8:15:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[NumberOfDaysInMonthGregorian]
(
@Year int
,@Month int
)
RETURNS int
AS
BEGIN

DECLARE @ResultVar int
if(@Month<>2)
begin
set @ResultVar=30+((@Month + FLOOR(@Month/8)) % 2)
end
else
begin
if(dbo.IsLeapYear(@Year)=1)
begin
set @ResultVar=29
end
else
begin
set @ResultVar=28
end
end

RETURN @ResultVar

END
GO
/****** Object:  Table [dbo].[Anticipation]    Script Date: 9/7/2020 8:15:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Anticipation](
	[Namad] [nvarchar](max) NOT NULL,
	[TradingDate] [varchar](10) NOT NULL,
	[CountOfPortion] [int] NULL,
	[Cost] [int] NULL,
	[RealCost] [int] NULL,
	[ShoppingCost] [int] NULL,
	[ShoppingDate] [varchar](10) NULL,
	[EstimationCost] [int] NULL,
	[EstimationDate] [varchar](10) NULL,
	[FirstOffer] [bit] NULL,
	[IsInTrading] [bit] NULL,
	[OwnerName] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Basket]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Basket](
	[Namad] [nvarchar](max) NOT NULL,
	[TradingDate] [varchar](10) NOT NULL,
	[CountOfPortion] [int] NULL,
	[AvverageCost] [int] NULL,
	[RealCost] [int] NULL,
	[FirstOffer] [bit] NULL,
	[OwnerName] [nvarchar](50) NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[InvestmentType] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[GroupId] [bigint] NULL,
	[BrokerName] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BasketGroup]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BasketGroup](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_BasketGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BasketOwner]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BasketOwner](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[GroupId] [int] NULL,
 CONSTRAINT [PK_BasketOwner] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BasketShopping]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BasketShopping](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[BasketID] [bigint] NOT NULL,
	[ShoppingDate] [varchar](10) NOT NULL,
	[ShopCount] [int] NOT NULL,
	[ShoppingCost] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_BasketShopping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BuySell]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuySell](
	[IndividualBuyCount] [bigint] NULL,
	[LegalBuyCount] [bigint] NULL,
	[IndividualSellCount] [bigint] NULL,
	[LegalSellCount] [bigint] NULL,
	[IndividualBuyAmount] [bigint] NULL,
	[LegalBuyAmount] [bigint] NULL,
	[IndividualSellAmount] [bigint] NULL,
	[LegallSellAmount] [bigint] NULL,
	[TradingDate] [varchar](10) NULL,
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_BuySell] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Charity]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Charity](
	[CharityDate] [varchar](10) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[HelpAmount] [bigint] NULL,
	[Owner] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CharityDetails]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CharityDetails](
	[ShopDate] [varchar](10) NULL,
	[StuffName] [nvarchar](500) NULL,
	[Cost] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Industry]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Industry](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Industry] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MasterTransaction]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterTransaction](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ActivityType] [nvarchar](500) NULL,
	[Description] [nvarchar](max) NULL,
	[ActivityDate] [varchar](10) NULL,
	[Debtor] [bigint] NULL,
	[Creditor] [bigint] NULL,
	[Remaind] [bigint] NULL,
	[BrokerName] [nvarchar](50) NULL,
	[OwnerName] [nvarchar](50) NULL,
 CONSTRAINT [PK_MaterTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Namad]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Namad](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Namad] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[GeneralCode] [nvarchar](max) NULL,
	[tseID] [bigint] NULL,
	[EnNamad] [varchar](50) NULL,
	[EnName] [varchar](50) NULL,
	[NamadGroup] [varchar](50) NULL,
	[TableName] [nvarchar](max) NULL,
	[IndustryID] [bigint] NULL,
 CONSTRAINT [PK_Namad] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NamadHistory]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NamadHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TradingDate] [varchar](10) NOT NULL,
	[NamadId] [bigint] NOT NULL,
	[Tedad] [bigint] NOT NULL,
	[Hajm] [bigint] NOT NULL,
	[Arzesh] [bigint] NOT NULL,
	[Dirooz] [bigint] NOT NULL,
	[AvvalinGheymat] [bigint] NOT NULL,
	[AkharinGheymat] [bigint] NOT NULL,
	[KamtarinGheymat] [bigint] NOT NULL,
	[BishtarinGheymat] [bigint] NOT NULL,
	[PayaniGheymat] [bigint] NOT NULL,
	[AkharinTaghyeer] [bigint] NULL,
	[AkharinDarsad] [float] NULL,
	[PayaniTaghyeer] [bigint] NULL,
	[PayaniDarsad] [float] NULL,
	[BuyTedad] [int] NULL,
	[ShopTedad] [int] NULL,
	[BuyHajm] [bigint] NULL,
	[ShopHajm] [bigint] NULL,
	[BuyCost] [bigint] NULL,
	[ShopCost] [bigint] NULL,
 CONSTRAINT [PK_NamadHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NamadNotify]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NamadNotify](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[tseID] [bigint] NULL,
	[AnnounceDate] [varchar](16) NULL,
	[Title] [nvarchar](max) NULL,
	[NamadId] [bigint] NOT NULL,
 CONSTRAINT [PK_NamadNotify] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Payments]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentDate] [varchar](10) NULL,
	[Amount] [bigint] NULL,
	[OwnerName] [nvarchar](50) NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[BrokerName] [nvarchar](50) NULL,
	[TransactionType] [nvarchar](50) NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  StoredProcedure [dbo].[procCalculateMemberBenefits]    Script Date: 9/7/2020 8:15:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[procCalculateMemberBenefits]
	@GroupId as int
	-- Add the parameters for the stored procedure here
AS
BEGIN

declare @TotalPayment as bigint;
declare @TotalBenefit as bigint;
declare @TotalDays as int;
declare @SumOfDivisionOnDays as float;

with totalPayment as 
(select sum(amount) totalPayment from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId)) 
select @TotalPayment=totalPayment from totalPayment;

with totalBenefit as 
(select sum(TotalMoney.TotalMoney)-sum(totalPeyment.totalPayment) TotalBenefit from 
(select bsk.OwnerName  , (select sum(amount)
from Payments where OwnerName = bsk.OwnerName and OwnerName in (select Name from BasketOwner where GroupId = @GroupId)) totalPayment from
(select ownername , sum(CountOfPortion*RealCost*-1) cost  from basket where GroupId = @GroupId group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost from BasketShopping bs inner join Basket b on b.id = bs.BasketID where b.GroupId = @GroupId group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName 
) bsk 
group by bsk.OwnerName) as totalPeyment
inner join 
(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from (
select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat , 
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	 case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
	 when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
from Basket  b
inner join Namad n on n.Namad = b.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where b.GroupId = @GroupId ) as totalMoney
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName) 
select @TotalBenefit=TotalBenefit from totalBenefit;

with totalDays as 
(select sum (days.tradingDuration) totalDays from (
select  (select count(distinct tradingdate) days from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName) as pay) as days) 
select @TotalDays=totalDays from totalDays;

with sumOfdivisionOndays as
(select sum( finalClac1.divisionOnAvgDays) sumOfdivisionOndays from (
select tPayments.OwnerName , tPayments.OwnerPayment, tPaymentDuration.avgDays , round( (cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays, 5) divisionOnAvgDays  from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
group by duration.OwnerName) as tPaymentDuration,
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.TransactionType in (N'پرداخت' , N'برداشت') and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments
where tPayments.OwnerName = tPaymentDuration.OwnerName ) as finalClac1 ,

(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from 
	(select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat ,	

	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
	from Basket  b
	inner join Namad n on n.Namad = b.Namad
	inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
	inner join NamadHistory nh on nh.ID = nhStatus.maxID
	left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = @GroupId ) as totalMoney
	group by totalMoney.OwnerName) tMoney where tMoney.OwnerName = finalClac1.OwnerName
 )
select @SumOfDivisionOnDays=sumOfdivisionOndays from sumOfdivisionOndays;


--02
select tPayments.OwnerName , convert(bigint , tPayments.OwnerPayment ) OwnerPayment,
case when tWithdrawMoney.OwnerWithdraw is null then convert(bigint , 0) when tWithdrawMoney.OwnerWithdraw is not null then convert (bigint , tWithdrawMoney.OwnerWithdraw) end OwnerWithdraw ,
convert (bigint , tMoney.TotalRealCost ) TotalRealCost, convert (bigint , tMoney.TotalMoney) TotalMoney, tPaymentDuration.avgDays AvverageDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) DivisionOnAvgDays ,
case when tWithdrawMoney.OwnerWithdraw is null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5)
	when tWithdrawMoney.OwnerWithdraw is not null then round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5) + tWithdrawMoney.OwnerWithdraw  end FinalBenefitValue,
	 tDebtors.Debtors

 from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
	(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
	from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
	group by duration.OwnerName) as tPaymentDuration,

(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p 
	where p.TransactionType=N'پرداخت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments,

(select totalMoney.OwnerName , sum(totalMoney.TotalMoney) TotalMoney , sum(TRealCost) TotalRealCost from 
	(select OwnerName , b.TradingDate , n.Namad , RealCost , nh.PayaniGheymat ,	

	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  nh.PayaniGheymat*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then nh.PayaniGheymat*(b.CountOfPortion) end TotalMoney,
	case when bshStatus.ShopCount is not null then  
		case when b.CountOfPortion-bshStatus.ShopCount > 0 then  b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) 
		when b.CountOfPortion-bshStatus.ShopCount = 0 then 0  end  
		when bshStatus.ShopCount is null then b.RealCost*(b.CountOfPortion) end TRealCost
	from Basket  b
	inner join Namad n on n.Namad = b.Namad
	inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
	inner join NamadHistory nh on nh.ID = nhStatus.maxID
	left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = @GroupId ) as totalMoney
	group by totalMoney.OwnerName) tMoney
	left outer join 
	(select p.OwnerName , sum(Amount) OwnerWithdraw  from Payments p 
	where p.TransactionType=N'برداشت' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tWithdrawMoney on tMoney.OwnerName = tWithdrawMoney.OwnerName,

(select bsk.OwnerName , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(bsk.cost)),1), '.00','') Debtors from
(select ownername , sum(CountOfPortion*RealCost*-1) cost from basket group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost  from Payments p group by p.OwnerName 
) bsk
group by bsk.OwnerName) tDebtors

where tPayments.OwnerName = tPaymentDuration.OwnerName and tMoney.OwnerName = tPayments.OwnerName  and tDebtors.OwnerName = tPayments.OwnerName ;
END

GO
