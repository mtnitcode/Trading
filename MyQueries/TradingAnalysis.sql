use Trading

--select dbo.GregorianToPersian ('2020/04/15');
select replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-');

declare @preTowMonth as varchar(10) = '1398-12-01';
declare @preMonth as varchar(10) = '1398-12-01';
declare @preWeek as varchar(10) = '1398-12-23';
declare @pre2Week as varchar(10) = '1398-12-23';
declare @pre3Week as varchar(10) = '1398-12-23';

declare @Today as varchar(10)
declare @LastTradingDate as varchar(10)

declare @SelectedIndustries as varchar(MAX) = '53 , 44 , 27 ,28, 34,38 , 43 , 65 , 56 , 57 , 58 , 1 , 72';
declare @Yesterday as varchar(10)

Select top 1 * from NamadHistory order by id desc

select @Yesterday=replace(REPLACE(dbo.GregorianToPersian(CONVERT (date , dateadd(day , -2 , getdate())) ),'-','/') , '/' ,'-');
print '@Yesterday : ' + @Yesterday;

select @Today=replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-');

print @Today;

with trd as 
(select distinct top 1 tradingdate from namadhistory order by tradingdate desc)
select @LastTradingDate=tradingdate from trd
print '@LastTradingDate : ' + @LastTradingDate;

with trd as 
(select distinct top 20 tradingdate from namadhistory order by tradingdate desc)
select @preMonth=min(tradingdate) from trd
print '@preMonth :' + @preMonth;

with trd as 
(select distinct top 40 tradingdate from namadhistory order by tradingdate desc)
select @preTowMonth=min(tradingdate) from trd
print '@preTowMonth :' + @preTowMonth;

with trd as 
(select distinct top 15 tradingdate from namadhistory order by tradingdate desc)
select @pre3Week=min(tradingdate) from trd
print '@pre3Week :' + @pre3Week;

with trd as 
(select distinct top 10 tradingdate from namadhistory order by tradingdate desc)
select @pre2Week=min(tradingdate) from trd
print '@pre2Week :' + @pre2Week;

with trd as 
(select distinct top 5 tradingdate from namadhistory order by tradingdate desc)
select @preWeek=min(tradingdate) from trd
print '@preWeek :' +  @preWeek;

select ind.Id , ind.Name , FirstWeek.FirstOfMonthSum 'درصدتغییرات هفته اول' , SecondWeek.SecondWeekSum 'درصدتغییرات هفته دوم'  , lastw.lastWeekSum 'درصدتغییرات هفته آخر'   
  from 
	Industry ind inner join 
  (select nn.IndustryID, avg(nhh.PayaniDarsad) FirstOfMonthSum , avg(nhh.Tedad) FirstOfMonthTedad  from NamadHistory nhh inner join Namad nn on nn.ID = nhh.NamadId where nhh.PayaniDarsad < 20 and  nhh.TradingDate between @preMonth and  @pre2Week group by nn.IndustryID ) FirstWeek  on FirstWeek.IndustryID = ind.Id
  inner join (select nn.IndustryID, avg(nhh.PayaniDarsad) SecondWeekSum , avg(nhh.Tedad) FirstOfMonthTedad  from NamadHistory nhh inner join Namad nn on nn.ID = nhh.NamadId where nhh.PayaniDarsad < 20 and  nhh.TradingDate between @pre2Week and @preWeek group by nn.IndustryID ) SecondWeek on SecondWeek.IndustryID = ind.ID
  inner join (select nn.IndustryID, avg(nhh.PayaniDarsad) lastweekSum , avg(nhh.Tedad) FirstOfMonthTedad  from NamadHistory nhh inner join Namad nn on nn.ID = nhh.NamadId  where nhh.PayaniDarsad < 20 and  nhh.TradingDate > @preWeek group by nn.IndustryID ) lastw on lastw.IndustryID = ind.Id
  order by lastw.lastWeekSum;

--------------- 
select * from (
select  ind.Name IndName , nmd.Name , nmd.namad 'تمام‌نمادها',PreMonth.PreMonthSum 'درصدتغییرات‌کل‌ماه‌گذشته',total.TotalSum 'درصدتغییرات‌کل‌ماه‌جاری',  FirstWeek.FirstOfMonthSum 'درصدتغییرات‌هفته‌دوم' , SecondWeek.SecondWeekSum 'درصدتغییرات‌هفته‌سوم' , lastw.lastWeekSum 'درصدتغییرات‌هفته‌آخر' ,nh.PayaniDarsad 'درصدتغییرات‌زورآخر' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat),1), '.00','') 'قیمت پ', REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') N'حجم تقاضا' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') N'حجم عرضه'
,case when FirstOfMonthSum <0 and SecondWeekSum <0 and lastWeekSum <0 then 0
	 when FirstOfMonthSum <0 and SecondWeekSum <0 and lastWeekSum >0 then 1
	 when FirstOfMonthSum <0 and SecondWeekSum >0 and lastWeekSum <0 then 2
	 when FirstOfMonthSum <0 and SecondWeekSum >0 and lastWeekSum >0 then 3
	 when FirstOfMonthSum >0 and SecondWeekSum <0 and lastWeekSum <0 then 4
	 when FirstOfMonthSum >0 and SecondWeekSum <0 and lastWeekSum >0 then 5
	 when FirstOfMonthSum >0 and SecondWeekSum >0 and lastWeekSum <0 then 6
	 when FirstOfMonthSum >0 and SecondWeekSum >0 and lastWeekSum >0 then 7 end 'دسته بندی'
  from 
	namad nmd inner join 
             (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) FirstOfMonthSum , avg(nhh.Tedad) FirstOfMonthTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and  nhh.TradingDate between @pre3Week and  @pre2Week group by nhh.NamadId ) FirstWeek  on FirstWeek.NamadId = nmd.ID 
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) PreMonthSum , avg(nhh.Tedad) PreMonthTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate between @preTowMonth and @preMonth group by nhh.NamadId ) PreMonth on PreMonth.NamadId = nmd.ID
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) SecondWeekSum , avg(nhh.Tedad) SecondWeekTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate between @pre2Week and @preWeek group by nhh.NamadId ) SecondWeek on SecondWeek.NamadId = nmd.ID
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) lastWeekSum , avg(nhh.Tedad) lastWeekTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate > @preWeek group by nhh.NamadId ) lastw on lastw.NamadId = nmd.ID
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) TotalSum , avg(nhh.Tedad) TotalTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate > @preMonth group by nhh.NamadId ) total on total.NamadId = nmd.ID
  inner join (select nhh.NamadId, max(nhh.ID) maxStateID from NamadHistory nhh where nhh.TradingDate > @preMonth group by nhh.NamadId ) maxNamadState on maxNamadState.NamadId = nmd.ID
  inner join NamadHistory nh on nh.ID = maxNamadState.maxStateID
  left join Industry ind on ind.id = nmd.IndustryID
  where --ind.Id in (select value FROM string_split(@SelectedIndustries, ','))
   nmd.Namad not like '%[0-9]%') namads
  order by namads.[دسته بندی], namads.درصدتغییرات‌کل‌ماه‌جاری , namads.درصدتغییرات‌هفته‌دوم, namads.درصدتغییرات‌هفته‌سوم , namads.درصدتغییرات‌هفته‌آخر ;


select * from (
select  ind.Name IndName , nmd.Name , nmd.namad 'نمادهای خودم',total.TotalSum 'درصدتغییرات‌کل', 
	 case when bshStatus.ShopCount is not null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 
	 when bshStatus.ShopCount is null then (ROUND( (convert(float, nh.PayaniGheymat) / b.RealCost)-1 , 5 ))*100 end 'درصد‌س/ز‌خالص' ,
 FirstWeek.FirstOfMonthSum 'درصدتغییرات‌هفته‌دوم' , SecondWeek.SecondWeekSum 'درصدتغییرات‌هفته‌سوم' , lastw.lastWeekSum 'درصدتغییرات‌هفته‌آخر' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.PayaniGheymat),1), '.00','') 'قیمت پ', REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.BuyHajm),1), '.00','') N'حجم تقاضا' , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,nh.ShopHajm),1), '.00','') N'حجم عرضه',
case when FirstOfMonthSum <0 and SecondWeekSum <0 and lastWeekSum <0 then 0
	 when FirstOfMonthSum <0 and SecondWeekSum <0 and lastWeekSum >0 then 1
	 when FirstOfMonthSum <0 and SecondWeekSum >0 and lastWeekSum <0 then 2
	 when FirstOfMonthSum <0 and SecondWeekSum >0 and lastWeekSum >0 then 3
	 when FirstOfMonthSum >0 and SecondWeekSum <0 and lastWeekSum <0 then 4
	 when FirstOfMonthSum >0 and SecondWeekSum <0 and lastWeekSum >0 then 5
	 when FirstOfMonthSum >0 and SecondWeekSum >0 and lastWeekSum <0 then 6
	 when FirstOfMonthSum >0 and SecondWeekSum >0 and lastWeekSum >0 then 7 end 'دسته بندی',
	 case when bshStatus.ShopCount is not null then b.CountOfPortion-bshStatus.ShopCount when bshStatus.ShopCount is null then b.CountOfPortion end 'تعدادسهم' , b.OwnerName
  from 
	namad nmd inner join 
  (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) FirstOfMonthSum , avg(nhh.Tedad) FirstOfMonthTedad  from NamadHistory nhh where nhh.PayaniDarsad <=100 and nhh.TradingDate between @pre3Week and  @pre2Week group by nhh.NamadId ) FirstWeek  on FirstWeek.NamadId = nmd.ID 
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) SecondWeekSum , avg(nhh.Tedad) SecondWeekTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate between @pre2Week and @preWeek group by nhh.NamadId ) SecondWeek on SecondWeek.NamadId = nmd.ID
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) lastWeekSum , avg(nhh.Tedad) lastWeekTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate > @preWeek group by nhh.NamadId ) lastw on lastw.NamadId = nmd.ID
  inner join (select nhh.NamadId, round(avg(nhh.PayaniDarsad) , 3) TotalSum , avg(nhh.Tedad) TotalTedad  from NamadHistory nhh where  nhh.PayaniDarsad <=100 and nhh.TradingDate > @preMonth group by nhh.NamadId ) total on total.NamadId = nmd.ID
  inner join (select nhh.NamadId, max(nhh.ID) maxStateID from NamadHistory nhh where nhh.TradingDate > @preMonth group by nhh.NamadId ) maxNamadState on maxNamadState.NamadId = nmd.ID
  inner join NamadHistory nh on nh.ID = maxNamadState.maxStateID
  left join Industry ind on ind.id = nmd.IndustryID
  inner join Basket b on b.Namad = nmd.Namad
  left outer join (select BasketID , sum(ShopCount) ShopCount from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id
  inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
  where --ind.Id in (select value FROM string_split(@SelectedIndustries, ','))
   nmd.Namad not like '%[0-9]%' ) mynamads
   where mynamads.تعدادسهم > 0
  order by mynamads.[دسته بندی],mynamads.درصدتغییرات‌کل , mynamads.درصدتغییرات‌هفته‌دوم , mynamads.درصدتغییرات‌هفته‌سوم, mynamads.درصدتغییرات‌هفته‌آخر  desc;


-- 

-- نمادهایی که با 5الی 10 درصد ضرر بایست تعدیل 20 درصدی گردند
select bb.OwnerName 'تعدیل 20 درصدی روی ضرر', bb.TradingDate , bb.Namad , nmds.remained ,  bb.RealCost ,(ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 'درصد زیان' from basket bb inner join 
(
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , 0 shopcount , b.CountOfPortion remained from Basket b where id not in (select basketid from BasketShopping)
union
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , sh.shopcount , b.CountOfPortion-sh.shopcount remained from Basket b inner join 
(select basketid , sum(ShopCount) shopcount from BasketShopping group by BasketID) sh on b.id = sh.BasketID
where b.CountOfPortion- sh.shopcount > 0 ) Nmds on Nmds.id = bb.id
inner join Namad n on n.Namad = bb.namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
where (ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 < -5
and bb.id not in (select basketid from BasketShopping where ShoppingDate > replace(REPLACE(dbo.GregorianToPersian(CONVERT (date , dateadd(day , -5 , getdate())) ),'-','/') , '/' ,'-'))
and nh.PayaniDarsad < 0
order by bb.OwnerName , bb.TradingDate;


select bb.id , bb.OwnerName 'تعدیل 20 درصدی روی سود', bb.TradingDate , bb.Namad , nmds.remained ,  bb.RealCost ,(ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 'درصد سود' , bb.InvestmentType,
nh.BuyHajm
from basket bb inner join 
(
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , 0 shopcount , b.CountOfPortion remained from Basket b where id not in (select basketid from BasketShopping)
union
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , sh.shopcount , b.CountOfPortion-sh.shopcount remained from Basket b inner join 
(select basketid , sum(ShopCount) shopcount from BasketShopping group by BasketID ) sh on b.id = sh.BasketID
where b.CountOfPortion- sh.shopcount > 0 ) Nmds on Nmds.id = bb.id
inner join Namad n on n.Namad = bb.namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
where (ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 > 10
and bb.id not in (select basketid from BasketShopping where ShoppingDate > replace(REPLACE(dbo.GregorianToPersian(CONVERT (date , dateadd(day , -5 , getdate())) ),'-','/') , '/' ,'-'))
and  bb.FirstOffer is null
order by bb.OwnerName , bb.TradingDate;

select bb.id , bb.OwnerName 'تعدیل 30 درصدی‌کندی بازارطی‌دوهفته‌آخر', bb.TradingDate , bb.Namad , nmds.remained ,  bb.RealCost ,(ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 'درصد زیان' , bb.InvestmentType,
nh.BuyHajm
from basket bb inner join 
(
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , 0 shopcount , b.CountOfPortion remained from Basket b where id not in (select basketid from BasketShopping)
union
select b.id , b.OwnerName , b.Namad , b.TradingDate ,  b.countofportion , sh.shopcount , b.CountOfPortion-sh.shopcount remained from Basket b inner join 
(select basketid , sum(ShopCount) shopcount from BasketShopping group by BasketID ) sh on b.id = sh.BasketID
where b.CountOfPortion- sh.shopcount > 0 ) Nmds on Nmds.id = bb.id
inner join Namad n on n.Namad = bb.namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = n.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
where (ROUND( (convert(float, nh.PayaniGheymat) / bb.RealCost)-1 , 5 ))*100 < 10
and bb.TradingDate < @pre2Week
and bb.id not in (select basketid from BasketShopping where ShoppingDate > replace(REPLACE(dbo.GregorianToPersian(CONVERT (date , dateadd(day , -5 , getdate())) ),'-','/') , '/' ,'-'))
and  bb.FirstOffer is null
order by bb.OwnerName , bb.TradingDate;


select REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,sum(Inv.realvalue) ),1), '.00','') 'نسبت سرمایه گذاری', inv.InvestmentType , 
round(sum(Inv.realvalue)/convert(float, total.TotalValue) , 5)*100 from 
(select 
case when bshStatus.ShopCount is not null then (b.CountOfPortion-bshStatus.ShopCount)*RealCost 
when bshStatus.ShopCount is null then b.CountOfPortion*RealCost end RealValue 
, investmenttype ,b.CountOfPortion, bshStatus.ShopCount from Basket b 
left outer join (select BasketID , sum(ShopCount) ShopCount from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id) Inv ,
(select sum(Total.totalvalue) TotalValue from (
select case when bshStatus.ShopCount is not null then (b.CountOfPortion-bshStatus.ShopCount)*RealCost 
when bshStatus.ShopCount is null then b.CountOfPortion*RealCost end TotalValue 
 from Basket b 
left outer join (select BasketID , sum(ShopCount) ShopCount from BasketShopping group by BasketID) bshStatus on bshStatus.BasketID = b.id) Total) total
where inv.RealValue > 0 group by inv.InvestmentType , total.TotalValue ;
 
-------------------
SELECT ind.Name ,nm.Name , nm.Namad 'سود های ماه پیش'
      ,sum(PayaniDarsad)
  FROM [Trading].[dbo].[NamadHistory] nh inner join Namad nm on nm.ID =nh.NamadId
  left join Industry ind on ind.Id = nm.IndustryID
    where TradingDate > @preMonth
  group by ind.Name,nm.Name , nm.Namad
  having sum(PayaniDarsad) > 5 and sum(PayaniDarsad) < 100
  order by sum(PayaniDarsad) ;
------------------------

  select distinct n.ID, nf.AnnounceDate , nf.Title , n.Namad , n.Name from NamadNotify nf inner join namad n on n.ID = nf.NamadId 
  where title not like N'%ترکیب اعضای هیئت مدیره%' and title not like N'%صورت‌های مالی  سال مالی منتهی به%' and  Title not like N'%اطلاع رسانی%' and Title not like N'%ماهه منتهی به%'
  and title != N'آگهی دعوت به مجمع عمومی عادی بطور فوق العاده' and title not like N'%مشخصات کمیته حسابرسی%'
  and title != N'تصمیمات مجمع صندوق سرمایه گذاری' --and title not like N'%افشای اطلاعات بااهمیت%'
  and nf.AnnounceDate > @preTowMonth
  order by nf.AnnounceDate desc

  select distinct n.ID, nf.AnnounceDate , nf.Title , n.Namad , n.Name from NamadNotify nf inner join namad n on n.ID = nf.NamadId 
  inner join Basket b on b.Namad = n.Namad
  where title not like N'%ترکیب اعضای هیئت مدیره%' and title not like N'%صورت‌های مالی  سال مالی منتهی به%' and  Title not like N'%اطلاع رسانی%' and Title not like N'%ماهه منتهی به%'
  and title != N'آگهی دعوت به مجمع عمومی عادی بطور فوق العاده' and title not like N'%مشخصات کمیته حسابرسی%'
  and title != N'تصمیمات مجمع صندوق سرمایه گذاری' --and title not like N'%افشای اطلاعات بااهمیت%'
  and nf.AnnounceDate > @preTowMonth
  order by nf.AnnounceDate desc

-------------------

select  N'پیش بینی' , nmd.namad  'نمادها       ' , 
(select sum(PayaniDarsad)  from NamadHistory where PayaniDarsad < 20 and TradingDate >= b.TradingDate and NamadId = nmd.ID) 'درصد تغییرات' ,
b.TradingDate ' تاریخ خرید ' ,b.CountOfPortion 'تعداد', b.Cost 'قیمت خرید', b.RealCost 'قیمت خرید کارگزاری' , b.RealCost*b.CountOfPortion 'قیمت تمام شده' , b.ShoppingCost ' قیمت فروش', nh.PayaniGheymat 'قیمت پایانی' ,
case when b.ShoppingDate is null then (nh.PayaniGheymat - b.RealCost) * b.CountOfPortion when b.ShoppingDate is not null then (b.ShoppingCost - b.RealCost) * b.CountOfPortion end 'مبلغ سود/زیان'
,case when b.ShoppingDate is null then (ROUND( (convert(float, nh.PayaniGheymat) / b.Cost)-1 , 5 ))*100 when b.ShoppingDate is not null then (ROUND( (convert(float, b.ShoppingCost) / b.Cost)-1 , 5 ))*100 end 'درصد سود/زیان' 
, case when b.ShoppingDate is null then nh.PayaniGheymat * b.CountOfPortion when b.ShoppingDate is not null then 0 end 'کل سرمایه باحتساب سود/زیان' 
, b.FirstOffer ,b.OwnerName , nmd.namad  'نمادها      ' , b.ShoppingDate ' تاریخ فروش'  ,  b.ShoppingCost * b.CountOfPortion 'مبلغ حاصل از فروش' ,
case when b.ShoppingDate is null then 0 when b.ShoppingDate is not null then (ROUND( (convert(float, nh.PayaniGheymat) / b.ShoppingCost)-1 , 5 ))*100 end 'درصد سود/زیان پس از فروش ',
case when b.ShoppingDate is null then 0 when b.ShoppingDate is not null then (nh.PayaniGheymat - b.ShoppingCost) * b.CountOfPortion end 'مبلغ سود/زیان پس از فروش',
nh.Tedad 'تعداد معامله در آخرین روز'
from Namad nmd
inner join Anticipation b on b.Namad = nmd.Namad
inner join (select max(id) maxID , NamadId from NamadHistory group by NamadId) nhStatus on nhStatus.NamadId = nmd.ID
inner join NamadHistory nh on nh.ID = nhStatus.maxID
--where b.OwnerName = N'خودم'
order by b.OwnerName, b.ShoppingDate , b.TradingDate;


 
 declare @Day as varchar(10)
 select @Day=replace(REPLACE(dbo.GregorianToPersian(CONVERT (date, SYSDATETIMEOFFSET()) ),'-','/') , '/' ,'-');
 --Declare necessary variables


 CREATE TABLE dbo.#tempTable
   ( 
   Namad nvarchar(MAX) NOT NULL, 
   TradingDate varchar(10), 
   PayaniDarsad float
   ) 

INSERT INTO dbo.#tempTable (namad , tradingdate , PayaniDarsad) 
select distinct nmd.namad , nh.tradingdate , nh.PayaniDarsad from NamadHistory nh 
inner join Namad nmd on nmd.ID = nh.NamadId 
inner join basket b on b.namad = nmd.namad
where nh.tradingdate > @preMonth  order by nh.TradingDate

DECLARE   @SQLQuery AS NVARCHAR(MAX);
DECLARE   @PivotColumns AS NVARCHAR(MAX);
--Get unique values of pivot column  
SELECT   @PivotColumns= COALESCE(@PivotColumns + ',','') + QUOTENAME(TradingDate)
FROM (SELECT DISTINCT TradingDate FROM dbo.#tempTable where TradingDate > @preMonth) AS PivotDates order by PivotDates.TradingDate;
--SELECT   @PivotColumns
--Create the dynamic query with all the values for 
--pivot column at runtime
SET   @SQLQuery = 
    N'SELECT Namad, ' +   @PivotColumns + ' 
    FROM dbo.#tempTable 
	PIVOT(sum(PayaniDarsad)
          FOR TradingDate IN (' + @PivotColumns + ')) AS P'
--SELECT   @SQLQuery
--Execute dynamic query
EXEC sp_executesql @SQLQuery

DECLARE   @SQLSumTable AS NVARCHAR(MAX);
Declare @PivotColumnsSum as  NVARCHAR(MAX);
set @PivotColumnsSum = Replace( @PivotColumns , ',' , '+');
print @PivotColumnsSum

CREATE TABLE dbo.#tempTable2
   (
   Namad nvarchar(MAX) NOT NULL, 
   SumOfBenefit float 
   );
set @SQLSumTable = 'insert into #temptable2 (namad,SumOfBenefit) select namad , (' + @PivotColumnsSum + ') from ('+@SQLQuery+') as pt';
print @SQLSumTable
EXEC sp_executesql @SQLSumTable
select * from #tempTable2;
DROP TABLE dbo.#tempTable
DROP TABLE dbo.#tempTable2
