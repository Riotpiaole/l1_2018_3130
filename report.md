# Report on Team Lab

----

## Question 1

* Create the database `Sailors`, `Boats` and `Reserves`. The code is provide below

```sql

create table Sailors (
    sid integer not null primary key,
    sname varchar(255),
    rating integer,
    age integer
);

create table Boats (
    bid integer not null primary key,
    bname varchar(255),
    color varchar(255)
);

create table Reserves(
    sid integer references Sailors(sid),
    bid integer references Boats(bid),
    day date primary key
);

```

## Question 2

* Populate the data base with huge numbers of data

```sql
-- retrieve from lab4 generating date with given range
DROP FUNCTION get_random_date(date,date);
CREATE OR REPLACE FUNCTION get_random_date(start_date date, end_date date) RETURNS Date AS
$BODY$
DECLARE  interval_days integer;  random_days integer;  random_date date;
BEGIN  interval_days := end_date -start_date;
random_days := random()*interval_days;
random_date := start_date + random_days;
RETURN random_date;END;
$BODY$  LANGUAGE plpgsql

-- Inserting 110 numbers of sailors
insert into sailors select generate_series(1,110),
(array['jack', 'Lubber','Bob','David'])[ceil(1 + random()*4)],
ceil(random()*(20-1)+10),ceil(random()*(30-1)+20);

-- Inserting 150 numbers of boats
insert into boats select generate_series(1,150),
(array['jack hammer','crowd','baki','hand'])[1+ random()*4],
(array['red','blue','green','orange'])[ceil(1+ random()*4)];

-- Inserting 110 numbers of reserves
insert into reserves select
generate_series(1,110),
generate_series(1,110),
get_random_date(
    to_date('01 Jan 1980', 'DD Mon YYYY'),
    to_date('31 Dec 2017', 'DD Mon YYYY')
);
```

## Question 3 and 4

1. Given question Find the names and ages of all sailors.
    * Query is `select s.sname , s.age from sailors s;`
    * The evaluation plan
    * ```sql
        Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
      ```

2. Given question Find the distinct names and ages of all sailors
    * Query is `select distinct s.sname , s.age from sailors s;
    * The evaluation plan
    * ```sql
        Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
      ```

3. Given question Find all sailors with a rating above 7.
    * Query is `select * from sailors s where s.age > 7;`
    * The evaluation plan
    * ```sql
        Seq Scan on sailors s  (cost=0.00..2.38 rows=110 width=17)
            Filter: (age > 7)
      ```

4. Given question Find the names of sailors who have reserved boat number 103
    * Query is `select s.sname from sailors s join reserves r on s.sid = r.sid where r.bid = 103;`
    * The evaluation plan
    * ```sql
        Hash Join  (cost=2.39..4.91 rows=1 width=5)
            Hash Cond: (s.sid = r.sid)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
            ->  Hash  (cost=2.38..2.38 rows=1 width=4)
                    ->  Seq Scan on reserves r  (cost=0.00..2.38 rows=1 width=4)
                        Filter: (bid = 103)
      ```

5. Given question Find the names of sailors who have reserved a red boat
    * Query is `select s.sname from sailors s , reserves r , boats b where s.sid  = r.sid and  r.bid = b.bid  and b.color = 'red';`
    * The evaluation plan
    * ```sql
        Nested Loop  (cost=3.03..5.56 rows=1 width=5)
            ->  Hash Join  (cost=2.89..5.29 rows=1 width=4)
                    Hash Cond: (r.bid = b.bid)
                    ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=8)
                    ->  Hash  (cost=2.88..2.88 rows=1 width=4)
                        ->  Seq Scan on boats b  (cost=0.00..2.88 rows=1 width=4)
                                Filter: ((color)::text = 'red'::text)
            ->  Index Scan using sailors_pkey on sailors s  (cost=0.14..0.27 rows=1 width=9)
                    Index Cond: (sid = r.sid)
      ```

6. Given question Find the colors of boats reserved by Lubber
    * Query is `select b.color from sailors s , reserves r , boats b where s.sid = r.sid and s.sname = 'Lubber';`
    * The evaluation plan
    * ```sql
        Nested Loop  (cost=2.69..54.52 rows=3750 width=6)
        ->  Seq Scan on boats b  (cost=0.00..2.50 rows=150 width=6)
        ->  Materialize  (cost=2.69..5.21 rows=25 width=0)
                ->  Hash Join  (cost=2.69..5.09 rows=25 width=0)
                    Hash Cond: (r.sid = s.sid)
                    ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=4)
                    ->  Hash  (cost=2.38..2.38 rows=25 width=4)
                            ->  Seq Scan on sailors s  (cost=0.00..2.38 rows=25 width=4)
                                Filter: ((sname)::text = 'Lubber'::text)
      ```

7. Given question Find the names of sailors who have reserved at least one boat
    * Query is `select s.sname from sailors s , reserves r  where s.sid = r.rid;`
    * The evaluation plan
    * ```sql
         Hash Join  (cost=3.48..5.87 rows=110 width=5)
            Hash Cond: (r.sid = s.sid)
            ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=4)
            ->  Hash  (cost=2.10..2.10 rows=110 width=9)
                    ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
      ```

8. Given question
    * Query is
        ```sql
            select s.sid, rating +1 as increments
                from sailors s , reserves r1 , reserves r2
            where s.sid = r1.sid
                and s.sid = r2.sid
                and r1.day = r2.day
                and r1.bid != r2.bid;
        ```
    * The evaluation plan
    * ```sql
        Nested Loop  (cost=3.89..6.70 rows=1 width=8)
            ->  Hash Join  (cost=3.75..6.43 rows=1 width=8)
                    Hash Cond: ((r1.sid = r2.sid) AND (r1.day = r2.day))
                    Join Filter: (r1.bid <> r2.bid)
                    ->  Seq Scan on reserves r1  (cost=0.00..2.10 rows=110 width=12)
                    ->  Hash  (cost=2.10..2.10 rows=110 width=12)
                        ->  Seq Scan on reserves r2  (cost=0.00..2.10 rows=110 width=12)
            ->  Index Scan using sailors_pkey on sailors s  (cost=0.14..0.27 rows=1 width=8)
                    Index Cond: (sid = r1.sid)
      ```

9. Given question Find the ages of sailors whose name begins and ends with B and has at least three characters
    * Query is `select s.age from sailors s where s.sname like '%b%' and length(s.sname) > 3;`
    * The evaluation plan
    * ```sql
         Seq Scan on sailors s  (cost=0.00..2.93 rows=19 width=4)
            Filter: (((sname)::text ~~ '%b%'::text) AND (length((sname)::text) > 3))
      ```

10.  Given question Find the names of sailors who have reserved a red or a green boat.
    * Query is
        ```sql
            select s.sname from
                sailors s join reserves r on s.sid = r.sid
                        join boats b on r.bid = b.bid
                            where b.color = 'red' or b.color = 'green';
        ```
    * The evaluation plan
    * ```sql
         Hash Join  (cost=6.39..9.15 rows=25 width=5)
            Hash Cond: (s.sid = r.sid)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
            ->  Hash  (cost=6.07..6.07 rows=25 width=4)
                    ->  Hash Join  (cost=3.67..6.07 rows=25 width=4)
                        Hash Cond: (r.bid = b.bid)
                        ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=8)
                        ->  Hash  (cost=3.25..3.25 rows=34 width=4)
                                ->  Seq Scan on boats b  (cost=0.00..3.25 rows=34 width=4)
                                    Filter: (((color)::text = 'red'::text) OR ((color)::text = 'green'::text))
      ```

11. Given question Find the names of sailors who have reserved both a red and a green boat.
    * Query is
        ```sql
            select s.sname from sailors s , reserves r , boats b
                where s.sid = r.sid
                        and r.bid = b.bid
                        and (b.color = 'red'
                                or b.color = 'green');
        ```
    * The evaluation plan
    * ```sql
       Hash Join  (cost=6.39..9.15 rows=25 width=5)
            Hash Cond: (s.sid = r.sid)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
            ->  Hash  (cost=6.07..6.07 rows=25 width=4)
                    ->  Hash Join  (cost=3.67..6.07 rows=25 width=4)
                        Hash Cond: (r.bid = b.bid)
                        ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=8)
                        ->  Hash  (cost=3.25..3.25 rows=34 width=4)
                                ->  Seq Scan on boats b  (cost=0.00..3.25 rows=34 width=4)
                                    Filter: (((color)::text = 'red'::text) OR ((color)::text = 'green'::text))
      ```

12. Given question Find the sids of all sailors who have reserved red boats but not green boats.
    * Query is
        ```sql
        select s.sname from sailors s , reserves r , boats b
            where s.sid = r.sid
                    and r.bid = b.bid
                    and b.color = 'red'
                    and not (b.color = 'green');
        ```
    * The evaluation plan
    * ```sql
         Nested Loop  (cost=3.41..5.93 rows=1 width=5)
            ->  Hash Join  (cost=3.26..5.66 rows=1 width=4)
                    Hash Cond: (r.bid = b.bid)
                    ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=8)
                    ->  Hash  (cost=3.25..3.25 rows=1 width=4)
                        ->  Seq Scan on boats b  (cost=0.00..3.25 rows=1 width=4)
                                Filter: (((color)::text <> 'green'::text) AND ((color)::text = 'red'::text))
            ->  Index Scan using sailors_pkey on sailors s  (cost=0.14..0.27 rows=1 width=9)
                    Index Cond: (sid = r.sid)
      ```

13. Given question Find all sids of sailors who have rating of 10 or reserved boat 104
    * Query is
        ```sql
        select s.sid from sailors s , reserves r
            where s.sid = r.sid and (s.rating = 10 or r.bid = 124);
        ```
    * The evaluation plan
    * ```sql
         Hash Join  (cost=3.48..5.86 rows=1 width=4)
            Hash Cond: (r.sid = s.sid)
            Join Filter: ((s.rating = 10) OR (r.bid = 124))
            ->  Seq Scan on reserves r  (cost=0.00..2.10 rows=110 width=8)
            ->  Hash  (cost=2.10..2.10 rows=110 width=8)
                    ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=8)
      ```

14. Given question Find the average age of all sailors.
    * Query is `select avg(s.age) from sailors s;`
    * The evaluation plan
    * ```sql
        Aggregate  (cost=2.38..2.39 rows=1 width=32)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=4)
      ```

15. Given question Find the average age of sailors with a rating of 10
    * Query is `select avg(s.age) from sailors s where s.rating = 10;`
    * The evaluation plan
    * ```sql
         Aggregate  (cost=2.38..2.39 rows=1 width=32)
            ->  Seq Scan on sailors s  (cost=0.00..2.38 rows=1 width=4)
                    Filter: (rating = 10)
      ```

16. Given question Find the name and age of the oldest sailor
    * Query is
        ```sql
            select s.sname , s.age from sailors  s where s.age in (
                select max(s1.age) msa from sailors s1);
        ```
    * The evaluation plan
    * ```sql
         Hash Join  (cost=0.30..2.73 rows=4 width=9)
            Hash Cond: (s.age = ($0))
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=9)
            ->  Hash  (cost=0.29..0.29 rows=1 width=4)
                    ->  Result  (cost=0.27..0.28 rows=1 width=4)
                        InitPlan 1 (returns $0)
                            ->  Limit  (cost=0.14..0.27 rows=1 width=4)
                                ->  Index Only Scan Backward using idx_sailor on sailors s1  (cost=0.14..14.07 rows=110 width=4)
                                        Index Cond: (age IS NOT NULL)
      ```

17. Given question Count the number of sailors
    * Query is `select count(s) from sailors s;`
    * The evaluation plan
    * ```sql
         Aggregate  (cost=2.38..2.38 rows=1 width=8)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=41)
      ```

18. Given question Count the number of different sailor names.
    * Query is `select  count( distinct (s.sname)) from sailors s;`
    * The evaluation plan
    * ```sql
         Aggregate  (cost=2.38..2.38 rows=1 width=8)
            ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=5)
      ```

19. Given question Find the age of the youngest sailor for each rating level.
    * Query is
        ```sql
            select s.age, s.rating from sailors s where s.age in (
                select min(s1.age) min_sa from sailors s1)
                order by s.rating;
        ```
    * The evaluation plan
    * ```sql
         Sort  (cost=2.77..2.78 rows=4 width=8)
            Sort Key: s.rating
            ->  Hash Join  (cost=0.30..2.73 rows=4 width=8)
                    Hash Cond: (s.age = ($0))
                    ->  Seq Scan on sailors s  (cost=0.00..2.10 rows=110 width=8)
                    ->  Hash  (cost=0.29..0.29 rows=1 width=4)
                        ->  Result  (cost=0.27..0.28 rows=1 width=4)
                                InitPlan 1 (returns $0)
                                ->  Limit  (cost=0.14..0.27 rows=1 width=4)
                                        ->  Index Only Scan using idx_sailor on sailors s1  (cost=0.14..14.07 rows=110 width=4)
                                            Index Cond: (age IS NOT NULL)
      ```

20. Given question Find the age of the youngest sailor who is eligible to vote (i.e., is at least 18 years old) for each rating level with at least two such sailors.
    * Query is
        ```sql
            select s2.rating from (
                select s.rating , min(s.age) as min_age  from sailors s
                    where s.age >= 18 group by s.rating
                having count(s.sid ) >= 2) as s2;
        ```
    * The evaluation plan
    * ```sql
         Subquery Scan on s2  (cost=2.92..3.30 rows=19 width=4)
            ->  HashAggregate  (cost=2.92..3.11 rows=19 width=8)
                    Group Key: s.rating
                    Filter: (count(s.sid) >= 2)
                    ->  Seq Scan on sailors s  (cost=0.00..2.38 rows=110 width=8)
                        Filter: (age >= 18)
      ```
