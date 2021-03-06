use Trading

--select dbo.GregorianToPersian ('2020/04/15');
select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-');

declare @preTowMonth as varchar(10) = '1398-12-01';
declare @preMonth as varchar(10) = '1398-12-01';
declare @preWeek as varchar(10) = '1398-12-23';
declare @preHalfMonth as varchar(10) = '1398-12-23';
declare @pre3Week as varchar(10) = '1398-12-23';

declare @Today as varchar(10)
declare @LastTradingDate as varchar(10)

declare @SelectedIndustries as varchar(MAX) = '53 , 44 , 27 ,28, 34,38 , 43 , 65 , 56 , 57 , 58 , 1 , 72';
declare @Yesterday as varchar(10)

Select top 1 * from NamadHistory order by id desc

select @Yesterday=replace(REPLACE(dbo.GregorianToPersian(CONVERT (date , dateadd(day , -2 , getdate())) ),'-','/') , '/' ,'-');
 
select @Today=replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-');

print @Today;

with trd as 
(select distinct top 1 tradingdate from namadhistory order by tradingdate desc)
select @LastTradingDate=tradingdate from trd
print '@LastTradingDate : ' + @LastTradingDate;

with trd as 
(select distinct top 22 tradingdate from namadhistory order by tradingdate desc)
select @preMonth=min(tradingdate) from trd
print '@preMonth :' + @preMonth;

with trd as 
(select distinct top 44 tradingdate from namadhistory order by tradingdate desc)
select @preTowMonth=min(tradingdate) from trd
print '@preTowMonth :' + @preTowMonth;

with trd as 
(select distinct top 15 tradingdate from namadhistory order by tradingdate desc)
select @pre3Week=min(tradingdate) from trd
print '@pre3Week :' + @pre3Week;

with trd as 
(select distinct top 10 tradingdate from namadhistory order by tradingdate desc)
select @preHalfMonth=min(tradingdate) from trd
print '@preHalfMonth :' + @preHalfMonth;

with trd as 
(select distinct top 5 tradingdate from namadhistory order by tradingdate desc)
select @preWeek=min(tradingdate) from trd
print '@preWeek :' +  @preWeek;

---------------
select totalPeyment.OwnerName , totalPeyment.[مجموع پرداخت/دریافت] , totalPeyment.[بدهکار/بستانکار] , TotalMoney.TotalRealCost , TotalMoney.TotalMoney from 
(
select bsk.OwnerName  , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') 
from Payments where OwnerName = bsk.OwnerName) 'مجموع پرداخت/دریافت' 
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(bsk.cost)),1), '.00','') 'بدهکار/بستانکار' from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName 
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
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id ) as totalMoney
group by totalMoney.OwnerName) as TotalMoney on TotalMoney.OwnerName = totalPeyment.OwnerName
order by TotalMoney.OwnerName 


-----

select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-') 'تاریخ گزارش', b.id 'کد خرید', b.OwnerName 'صاحب سهم', nmd.Name 'نام کامل' , nmd.namad  'نام نماد' ,
b.TradingDate 'تاریخ‌خرید' , b.CountOfPortion 'ت.سهم‌خریداری‌شده'
,case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end 'ت.سهم‌باقی.‌پس‌از‌ف.'
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.AvverageCost),1), '.00','') 'ق.خالص‌خ.‌یک‌سهم', REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost),1), '.00','') 'ق.تمام‌شده‌خرید1سهم'
,case when bshStatus.ShopCount is not null then  case when b.CountOfPortion-bshStatus.ShopCount > 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
		                                        when b.CountOfPortion-bshStatus.ShopCount = 0 then  REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','')  end  
	  when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,b.RealCost*(b.CountOfPortion)),1), '.00','') end 'ق.تمام‌شده‌خ.کل‌سهام'
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat),1), '.00','') 'ق.روز‌سهم' ,
case when b.CountOfPortion-bshStatus.ShopCount = 0 then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat*b.CountOfPortion - b.RealCost * (b.CountOfPortion) )),1), '.00','') 
	 when b.CountOfPortion-bshStatus.ShopCount > 0 then   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount) - b.RealCost*(b.CountOfPortion-bshStatus.ShopCount) )),1), '.00','')
	 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(nh.PayaniGheymat - b.RealCost) * (b.CountOfPortion)),1), '.00','') end 'مبلغ‌س/ز‌خالص' ,
case when bshStatus.ShopCount is not null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 
	 when bshStatus.ShopCount is null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 end 'درصد‌س/ز‌خالص'  , 
case when bshStatus.ShopCount is not null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion-bshStatus.ShopCount)),1), '.00','') 
	 when bshStatus.ShopCount is null then REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat * (b.CountOfPortion)),1), '.00','') end 'کل‌سرمایه‌باحتساب‌س/ز' 
, b.FirstOffer 'عرضه‌اولیه' ,
REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') 'حجم‌ف.درروزآخر' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') 'حجم‌خ.درروزآخر'
from Namad nmd
inner join Basket b on b.Namad = nmd.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
inner join NamadHistory nh on nh.ID = nhStatus.maxID
--where nmd.Namad = N'وغدير'
order by b.OwnerName , b.TradingDate;

----

 select trade.[نام نماد] 'وضعیت سبد سهام', sum(trade.[ت.سهم‌باقی.‌پس‌از‌ف.]) 'تعداد سهام' , trade.[ق.روز‌سهم], sum(trade.[کل‌سرمایه‌باحتساب‌س/ز]) 'ارزش سهام' from (
select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-') 'تاریخ گزارش', nmd.Name 'نام کامل' , nmd.namad  'نام نماد' ,
 b.CountOfPortion 'ت.سهم‌خریداری‌شده'
,case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end 'ت.سهم‌باقی.‌پس‌از‌ف.'
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.AkharinGheymat),1), '.00','') 'ق.روز‌سهم' ,
case when bshStatus.ShopCount is not null then nh.AkharinGheymat * (b.CountOfPortion-bshStatus.ShopCount) 
	 when bshStatus.ShopCount is null then nh.AkharinGheymat * (b.CountOfPortion) end 'کل‌سرمایه‌باحتساب‌س/ز' ,
REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') 'حجم‌ف.درروزآخر' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') 'حجم‌خ.درروزآخر'
from Namad nmd
inner join Basket b on b.Namad = nmd.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
left outer join (select BasketID , sum(ShopCount) ShopCount , AVG(ShoppingCost) ShopAvgCost from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
inner join NamadHistory nh on nh.ID = nhStatus.maxID) trade 
where trade.[ت.سهم‌باقی.‌پس‌از‌ف.] >0 group by trade.[نام نماد] , trade.[ق.روز‌سهم]
order by trade.[نام نماد];




----
select bsk.OwnerName 'گردش مالی' , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName and PaymentDate <= bsk.tdate) 'مجموع پرداخت/دریافت' , bsk.tdate 'تاریخ ' 
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost),1), '.00','') 'مبلغ خرید/فروش', bsk.ttype 'نوع گردش مالی' from
(select ownername , tradingdate tdate , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName , TradingDate
union
select b.OwnerName , shoppingdate tdate , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate
union
select p.OwnerName , p.PaymentDate tdate , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName , p.PaymentDate
) bsk
order by bsk.OwnerName , bsk.tdate

select bsk.OwnerName 'مجموع' , (select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(amount)),1), '.00','') from Payments where OwnerName = bsk.OwnerName) 'مجموع پرداخت/دریافت' 
, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,bsk.cost),1), '.00','') 'مبلغ خرید/فروش', bsk.ttype 'نوع گردش مالی' from
(select ownername , sum(CountOfPortion*RealCost*-1) cost , N'خرید' ttype from basket group by OwnerName 
union
select b.OwnerName , sum(ShopCount*ShoppingCost) cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName  
union
select p.OwnerName , sum(Amount) cost , N'پرداخت' ttype from Payments p group by p.OwnerName 
) bsk
order by bsk.OwnerName 



select b.OwnerName 'خرید/فروش',b.id id, shoppingdate tdate , b.Namad , bs.ShopCount , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(ShopCount*ShoppingCost)*-1),1), '.00','') cost , N'فروش' ttype from BasketShopping bs inner join Basket b on b.id = bs.BasketID group by b.OwnerName , ShoppingDate ,b.id, b.namad , bs.ShopCount 
union
select ownername 'خرید/فروش', id id , tradingdate tdate , Namad , CountOfPortion, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum( CountOfPortion*RealCost)),1), '.00','') cost  , N'خرید' ttype from basket group by TradingDate ,id, OwnerName , Namad , CountOfPortion 
order by tdate , b.OwnerName , b.Namad

