USE [Trading]
GO
/****** Object:  StoredProcedure [dbo].[procCalculateMemberBenefits]    Script Date: 9/21/2020 2:39:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[procCalculateMemberBenefits]
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
(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p where p.TransactionType in (N'واریز وجه' , N'برداشت وجه') and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments
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
select tPayments.OwnerName , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,tPayments.OwnerPayment ),1), '.00','') OwnerPayment,
case when tWithdrawMoney.OwnerWithdraw is null then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, 0 ),1), '.00','') when tWithdrawMoney.OwnerWithdraw is not null then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, tWithdrawMoney.OwnerWithdraw) ,1), '.00','') end OwnerWithdraw ,
REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,tMoney.TotalRealCost  ),1), '.00','') TotalRealCost, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,tMoney.TotalMoney),1), '.00','')  TotalMoney, tPaymentDuration.avgDays AvverageDays 
, round( (( cast( tPayments.OwnerPayment as float)/@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays , 5) DivisionOnAvgDays ,
case when tWithdrawMoney.OwnerWithdraw is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,round((((tPayments.OwnerPayment /@TotalDays)*tPaymentDuration.avgDays)/@SumOfDivisionOnDays) * @TotalBenefit , 0)),1), '.00','')
	 when tWithdrawMoney.OwnerWithdraw is not null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,round( (((tPayments.OwnerPayment /@TotalDays)*tPaymentDuration.avgDays) /@SumOfDivisionOnDays) * @TotalBenefit , 0) + tWithdrawMoney.OwnerWithdraw),1), '.00','')  end FinalBenefitValue,
	 tDebtors.Debtors

 from 
(select duration.OwnerName, avg(duration.dys) avgDays from 
	(select  ownerPay.tdate ,  ownerPay.OwnerName , (select count(distinct tradingdate) from NamadHistory where TradingDate >= ownerPay.tdate) dys
	from (select p.OwnerName , p.PaymentDate tdate from Payments p) ownerPay) as duration  
	group by duration.OwnerName) as tPaymentDuration,

(select p.OwnerName , sum(Amount) OwnerPayment  from Payments p 
	where p.TransactionType=N'واریز وجه' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tPayments,

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
	where p.TransactionType=N'برداشت وجه' and p.OwnerName in (select Name from BasketOwner where GroupId = @GroupId) group by p.OwnerName ) tWithdrawMoney on tMoney.OwnerName = tWithdrawMoney.OwnerName,

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

