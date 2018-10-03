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
