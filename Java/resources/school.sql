drop table if exists t_student;
	drop table if exists t_class;

	create table t_class(	
		cno int,
		cname varchar(255),
		primary key(cno)
	);
	create table t_student(
		sno int,
		sname varchar(255),
		classno int,
		foreign key(classno) references t_class(cno)
	);
	
	insert into t_class values(101,'xxxxxxxxxxxxxxxx');
	insert into t_class values(102,'yyyyyyyyyyyyyyyy');

	insert into t_student values (1,'zs1',101);	
	insert into t_student values (2,'zs2',101);
	insert into t_student values (3,'zs3',102);
	insert into t_student values (4,'zs4',102);
	insert into t_student values (5,'zs5',102);	
	insert into t_student values (6,'zs6',102);
	select * from t_class;
	select * from t_student;