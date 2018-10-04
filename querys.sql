-- 1.
select s.sname , s.age from sailors s;

-- 2.
select distinct s.sname , s.age from sailors s;

-- 3.
select * from sailors s where s.age > 7;

-- 4.
select s.sname from 
    sailors s join reserves r on s.sid = r.sid 
    where r.bid = 103;

-- 5. 
select s.sname from sailors s , reserves r , boats b 
    where s.sid  = r.sid and  r.bid = b.bid  and b.color = 'red';

-- 6.
select b.color from sailors s , reserves r , boats b 
    where s.sid = r.sid and s.sname = 'Lubber';

-- 7. 
select s.sname from sailors s , reserves r  where s.sid = r.rid;

-- 8. what is that mean
select s.sid, rating +1 as increments
    from sailors s , reserves r1 , reserves r2
where s.sid = r1.sid 
    and s.sid = r2.sid 
    and r1.day = r2.day 
    and r1.bid != r2.bid;
-- 9. 
select s.age from sailors s where s.sname like '%b%' and length(s.sname) > 3;

-- 10.
select s.sname from 
    sailors s join reserves r on s.sid = r.sid 
              join boats b on r.bid = b.bid
                where b.color = 'red' or b.color = 'green';

-- 11.
select s.sname from sailors s , reserves r , boats b 
    where s.sid = r.sid 
            and r.bid = b.bid 
            and (b.color = 'red' 
                    or b.color = 'green');

-- 12.
select s.sname from sailors s , reserves r , boats b 
    where s.sid = r.sid 
            and r.bid = b.bid 
            and b.color = 'red' 
            and not (b.color = 'green');
-- 13.
select s.sid from sailors s , reserves r 
    where s.sid = r.sid and (s.rating = 10 or r.bid = 124);

-- 14.
select avg(s.age) from sailors s;

-- 15. 
select avg(s.age) from sailors s where s.rating = 10;

-- 16.
select s.sname , s.age from sailors  s where s.age in ( 
    select max(s1.age) msa from sailors s1);

-- 17. 
select count(s) from sailors s;

-- 18. 
select  count( distinct (s.sname)) from sailors s;

-- 19.
select s.age, s.rating from sailors s where s.age in ( 
    select min(s1.age) min_sa from sailors s1)
    order by s.rating;

-- 20. under assumption of 18 is eligible to vote. 
select s2.rating from (
    select s.rating , min(s.age) as min_age  from sailors s
        where s.age >= 18 group by s.rating
    having count(s.sid ) >= 2) as s2;