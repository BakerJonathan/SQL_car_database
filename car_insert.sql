--So one of the two required stored functions is gonna be for people, cause I can copy past that three times with minimal changes
	--(They're all set up the same more or less)

create or replace function add_cust(_customer_id integer, _first_name varchar, _last_name varchar)
returns void as $MAIN$ begin 
	insert into customer(customer_id, first_name , last_name)
	values(_customer_id, _first_name , _last_name);
end;
$MAIN$
language plpgsql;

select add_cust(1,'Jonathan', 'Baker')

select add_cust(2, 'Caesar', 'Augustus')

select * from customer

drop function add_cust

--And we can copy paste that, switching for mechanic and salesperson

create or replace function add_mech(_id integer, _first_name varchar, _last_name varchar)
returns void as $MAIN$ begin 
	insert into mechanic(mechanic_id, first_name , last_name)
	values(_id, _first_name , _last_name);
end;
$MAIN$
language plpgsql;

select add_mech(1,'George', 'Bush')

select add_mech(2, 'Barrack', 'Obama')

select add_mech(3, 'Donald', 'Trump')

select add_mech(4, 'Joe', 'Biden')

select * from mechanic

drop function add_mech


create or replace function add_sales(_id integer, _first_name varchar, _last_name varchar)
returns void as $MAIN$ begin 
	insert into salesperson(sales_id, first_name , last_name)
	values(_id, _first_name , _last_name);
end;
$MAIN$
language plpgsql;

select add_sales(1,'George', 'Washington')

select add_sales(2, 'John', 'Adams')


select * from salesperson 

drop function add_sales

--I'll do normal inserts for everything else but invoice, one of the most involved
--Normal insertion feels simpler for data entries less than, say, 10, which realistically I probably won't go too much further than 2 (2-5 maybe) 

insert into car(car_id,make_model ,customer_id)
values(1,'Ford Focus',1)

insert into car(car_id,make_model ,customer_id)
values(2,'Hyundai Accent',1)

insert into car(car_id,make_model ,customer_id)
values(3,'Roman Chariot',2)

--invoice
create or replace function add_invoice(_inv_id integer, _inv_cost numeric(9,2), _car_id integer, _customer_id integer, _sales_id integer) --leaving date default
returns void as $MAIN$ begin 
	insert into invoice(invoice_id,inv_cost,car_id,customer_id,sales_id)
	values(_inv_id,_inv_cost,_car_id,_customer_id,_sales_id);
end;
$MAIN$
language plpgsql;

select add_invoice(1,6500.00,2,1,1)

select add_invoice(2,100000.00,3,2,2)

drop function add_invoice

--Service ticket has to be next (preceeding mech work and repair parts), again will just default the dates
insert into service_ticket (serv_id,serv_cost ,car_id , customer_id , serv_desc )
values(1, 10000, 3, 2, 'Oil change')

insert into service_ticket (serv_id,serv_cost ,car_id , customer_id , serv_desc )
values(2, 500, 3, 2, 'Fresh coat of paint on the horse')

insert into service_ticket (serv_id,serv_cost ,car_id , customer_id , serv_desc )
values(3, 850.24, 2, 1, 'Regular car examination')

insert into service_ticket (serv_id,serv_cost ,car_id , customer_id , serv_desc )
values(4, .01, 1, 1, 'Sponsored advertisement')


insert into mech_work  (mech_work, mechanic_id,serv_id)
values(1,2,2)

insert into mech_work  (mech_work, mechanic_id,serv_id)
values(2,3,4)

insert into mech_work  (mech_work, mechanic_id,serv_id)
values(3,1,3)

insert into mech_work  (mech_work, mechanic_id,serv_id)
values(4,4,1)

insert into mech_work  (mech_work, mechanic_id,serv_id)
values(5,4,4)

insert into mech_work  (mech_work, mechanic_id,serv_id)
values(6,3,2)



insert into repair_parts (rep_id, part_desc, serv_id)
values(1,'Oil',1)

insert into repair_parts (rep_id, part_desc, serv_id)
values(2,'Paint',2)

insert into repair_parts (rep_id, part_desc, serv_id)
values(3,'Logo sticker',3)


--And some joins to check things out a bit
--First an example of what a 'service record' would look like
select car.car_id, make_model, service_ticket.serv_id, serv_desc, serv_cost, serv_date, part_desc from car
inner join service_ticket  
on car.car_id=service_ticket.car_id 
full join repair_parts  
on service_ticket.serv_id=repair_parts.serv_id where car.car_id =3
--adjust car_id for the car you want records for

--Let's go customer to mechanic, and car to salesperson to check most of the connections out

--This theoretically is showing who worked on who's vehicle
select customer.customer_id, customer.first_name, customer.last_name, service_ticket.serv_id, mechanic.mechanic_id, mechanic.first_name, mechanic.last_name from customer 
full join service_ticket   
on service_ticket.customer_id =customer.customer_id 
full join mech_work on service_ticket.serv_id =mech_work.serv_id 
full join mechanic on mech_work.mechanic_id =mechanic.mechanic_id 

--And this shows what employees are selling the cars for 
select  car.car_id,make_model, inv_cost, inv_date, salesperson.sales_id, first_name, last_name from car 
inner join invoice on car.car_id=invoice.car_id
inner join salesperson on invoice.sales_id=salesperson.sales_id