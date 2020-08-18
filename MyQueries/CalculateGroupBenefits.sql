


select bsk.OwnerName 'گردش مالی' , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName and PaymentDate <= bsk.tdate) 'مجموع پرداخت/دریافت' , bsk.tdate 'تاریخ ' 
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost),1), '.00','') 'مبلغ خرید/فروش', bsk.ttype 'نوع گردش مالی' from
(select ownername , tradingdate tdate , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName , TradingDate
union
select b.OwnerName , shoppingdate tdate , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate
union
select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate
) bsk
order by bsk.OwnerName , bsk.tdate


select  ownerPay.tdate ,  ownerPay.OwnerName , ownerPay.amount, totalPay.paymentSum  ,  cast(ownerPay.amount as float)/cast( totalPay.paymentSum as float) from 
(
select pay.OwnerName, pay.tdate, (select sum(amount) from Payments where OwnerName = pay.OwnerName and PaymentDate <=pay.tdate) amount from 
(select p.OwnerName , p.PaymentDate tdate , sum(Amount) amount , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate)
pay group by pay.OwnerName , pay.tdate) ownerPay
inner join 
(select p.PaymentDate tdate , (select sum (amount) from Payments where PaymentDate <= p.PaymentDate) paymentSum , N'پرداخت' ttype from Payments p group by  p.PaymentDate) totalPay
on ownerPay.tdate = totalPay.tdate
order by ownerPay.OwnerName , ownerPay.tdate

-- محاسبه سود روزانه روی هر سهم موجود در پرتفوی
select * from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
order by basketHistory.basketDate,  basketHistory.Namad , basketHistory.historyDate


-- محاسبه سود روزانه
select basketHistory.historyDate , avg(basketHistory.PayaniDarsad) from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate
order by basketHistory.historyDate



-- daily benefit with names and total inversments
select baskethistory.* , basketOwners.Name 
from (
select basketHistory.historyDate , avg(basketHistory.PayaniDarsad) payaniDarsad , (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate) amount from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate) as baskethistory
, (select name from BasketOwner) basketOwners
order by basketOwners.Name , basketHistory.historyDate

-- daily benefit with names and total inversments
select * , bskOwners.amount*bskOwners.avgPayaniDarsad*0.01 totalBenefitInDay,  cast(bskOwners.OwnerAmount as float)/cast( bskOwners.amount as float) invPercent ,
 round( (bskOwners.amount*bskOwners.avgPayaniDarsad*0.01) *  (cast(bskOwners.OwnerAmount as float)/cast( bskOwners.amount as float)) , 3) personalBenefitInDay from (
select baskethistory.* , basketOwners.Name ,  (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate and OwnerName = basketOwners.Name) OwnerAmount 
from (
select basketHistory.historyDate , avg(basketHistory.PayaniDarsad) avgPayaniDarsad , (select sum(amount) from Payments where PaymentDate <=basketHistory.historyDate) amount from (
select b.TradingDate basketDate , nh.TradingDate historyDate,b.Namad , n.ID namadid ,  nh.PayaniDarsad , b.GroupId
, case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end countOfPortion
from NamadHistory nh inner join Namad n on n.ID = nh.NamadId
inner join Basket b on b.Namad = n.Namad 
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
where nh.TradingDate > b.TradingDate ) as basketHistory
where basketHistory.countOfPortion >0 and basketHistory.GroupId is not null
group by basketHistory.historyDate) as baskethistory
, (select name from BasketOwner) basketOwners) as bskOwners where bskOwners.OwnerAmount is not null
order by bskOwners.Name , bskOwners.historyDate





-update basket set GroupId = 1 where OwnerName !=N'خودم'
