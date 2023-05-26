--The people are all set up without FK, so those are first 
	--Also very similar
create table customer(
	customer_id SERIAL primary key,
	first_name VARCHAR (100),
	last_name VARCHAR (100)
);

create table salesperson(
	sales_id SERIAL primary key,
	first_name VARCHAR (100),
	last_name VARCHAR (100)
);

create table mechanic(
	mechanic_id SERIAL primary key,
	first_name VARCHAR (100),
	last_name VARCHAR (100)
);

--Then the car

create table car(
	car_id SERIAL primary key,
	make_model VARCHAR(200),
	customer_id integer, --Realistically they'd also have cars without owner, so we'll keep not null off here
	foreign key (customer_id) references customer(customer_id)
)

--From there we can add the service_ticket and invoice
create table service_ticket(
	serv_id SERIAL primary key,
	serv_cost numeric(7,2),
	serv_date date default current_date,
	car_id integer not null,
	foreign key (car_id) references car(car_id),
	customer_id integer not null,
	foreign key (customer_id) references customer(customer_id)
)

create table invoice(
	invoice_id SERIAL primary key,
	inv_cost numeric(9,2),
	inv_date date default current_date,
	car_id integer not null,
	foreign key (car_id) references car(car_id),
	customer_id integer not null,
	foreign key (customer_id) references customer(customer_id),
	sales_id integer not null,
	foreign key (sales_id) references salesperson(sales_id)
)

--And lastly those related to the service ticket, mech_work and repair_parts
create table mech_work(
	mech_work SERIAL primary key,
	mechanic_id integer not null,
	foreign key (mechanic_id) references mechanic(mechanic_id),
	serv_id integer not null,
	foreign key (serv_id) references service_ticket(serv_id)
)

create table repair_parts(
	rep_id SERIAL primary key,
	part_desc VARCHAR(250),
	serv_id integer not null,
	foreign key (serv_id) references service_ticket(serv_id)
)

--Some rationale:
	--Started with the components I wanted to be standalone, or closest to standalone 
	--People (customer, salesperson, and mechanics), would just be id and name
		--Car I wanted fairly standalone, but it made sense to tie in customer to car.
	--I then added the 'sale' charts (invoice and service_ticket)
		--I decided that salesperson doesn't need a direct connection to car, and could work through proxy of invoice
	--Service_ticket need a bit more work though
		--Many parts could be incorperated, thus we had the parts reference the service ticket
		--Many mechanics could work on many service tickets
			--For the many-to-many relationship I wanted a middle man table, and that table is mech_work
	--Lastly contemplated if I wanted 'service history' to be a real table, but decided, it could be called with car join service tickets without needing an actual table (see below)

alter table service_ticket  add serv_desc VARCHAR(400) --Figured this makes sense to add

select car.car_id, make_model, serv_id, serv_desc, serv_cost, serv_date from car
inner join service_ticket  
on car.car_id=service_ticket.car_id
