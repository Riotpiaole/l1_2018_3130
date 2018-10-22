DROP FUNCTION get_random_date(date,date);
CREATE OR REPLACE FUNCTION get_random_date(start_date date, end_date date) RETURNS Date AS
$BODY$
DECLARE  interval_days integer;  random_days integer;  random_date date;
BEGIN  interval_days := end_date -start_date;
random_days := random()*interval_days;
random_date := start_date + random_days;
RETURN random_date;END;
$BODY$  LANGUAGE plpgsql

insert into sailors select generate_series(1,110),
(array['jack', 'Lubber','Bob','David'])[ceil(1 + random()*4)],
ceil(random()*(20-1)+10),ceil(random()*(30-1)+20);

insert into boats select generate_series(1,150),
(array['jack hammer','crowd','baki','hand'])[1+ random()*4],
(array['red','blue','green','orange'])[ceil(1+ random()*4)];

insert into reserves select
generate_series(1,110),
generate_series(1,110),
get_random_date(
    to_date('01 Jan 1980', 'DD Mon YYYY'),
    to_date('31 Dec 2017', 'DD Mon YYYY')
);