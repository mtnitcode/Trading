USE [Trading]
GO

/****** Object:  StoredProcedure [dbo].[Trading_CalculateGroupPorsionStatus]    Script Date: 8/23/2020 7:21:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Trading_CalculateGroupPorsionStatus] 
	-- Add the parameters for the stored procedure here
	@GroupId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
declare @TotalPayment as bigint;
declare @TotalBenefit as bigint;
declare @TotalDays as int;
declare @SumOfDivisionOnDays as float;

with totalPayment as 
(select sum(amount) totalPayment from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1)) 
select @TotalPayment=totalPayment from totalPayment;

with totalBenefit as 
(select sum(TotalMoney.TotalMoney)-sum(totalPeyment.totalPayment) TotalBenefit from 
(select bsk.OwnerName  , (select sum(amount)
from Payments where OwnerName = bsk.OwnerName and OwnerName in (select Name from BasketOwner where GroupId = 1)) totalPayment from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket where GroupId = 1 group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID where b.GroupId = 1 group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName 
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
where b.GroupId = 1 ) as totalMoney
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName) 
select @TotalBenefit=TotalBenefit from totalBenefit;

with totalDays as 
(select sum (days.tradingDuration) totalDays from (
select  (select count(distinct tradingdate) days from NamadHistory where TradingDate >= pay.PaymentDat) tradingDuration
 from (select p.ownername , min(p.PaymentDate) paymentdat 
from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName) as pay) as days) 
select @TotalDays=totalDays from totalDays;

with sumOfdivisionOndays as
(select sum( finalClac1.divisionOnAvgDays) sumOfdivisionOndays from (
select tPayments.OwnerName , tPayments.OwnerPayment, tPaymentDuration.avgDays , round( (cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays, 5) divisionOnAvgDays  from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
group by duration.OwnerName) as tPaymentDuration,
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName ) tPayments
where tPayments.OwnerName = tPaymentDuration.OwnerName ) as finalClac1)
select @SumOfDivisionOnDays=sumOfdivisionOndays from sumOfdivisionOndays;


select tPayments.OwnerName , tPayments.OwnerPayment,tMoney.TotalRealCost , tMoney.TotalMoney , tPaymentDuration.avgDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) divisionOnAvgDays ,
round( (((cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 5)
 from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
group by duration.OwnerName) as tPaymentDuration,
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.OwnerName in (select Name from BasketOwner where GroupId = 1) group by p.OwnerName ) tPayments,
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
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id where b.GroupId = 1 ) as totalMoney
group by totalMoney.OwnerName) tMoney
where tPayments.OwnerName = tPaymentDuration.OwnerName and tMoney.OwnerName = tPayments.OwnerName

END

GO


