drop table if exists t_student;
drop table if exists t_class;
create table t_class(
cno int primary key,
cname varchar(255)
);

create table t_student(
sno int primary key, 
sname varchar(255), 
classno int,
foreign key(classno) references t_class(cno)
);

insert into t_class(cno, cname) values(101, 'xxxx'), (102, 'yyyy');
insert into t_student(sno, sname, classno) values(1, 'a', 101), (2, 'b', 102), (3, 'c', 101), (4, 'd', 101), (5, 'e', 102);
select * from t_class;
select * from t_student;