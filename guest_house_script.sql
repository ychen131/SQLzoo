/* Medium Difficulty Question 6 - 10 */

/* 6. Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury
for her room bookings. You should JOIN to the rate table using
room_type_requested and occupants. */

select sum(amount * nights) as amount_to_pay
from booking b
  join rate r on b.room_type_requested = r.room_type and b.occupants = r.occupancy
where guest_id = (select id
                  from guest
                  where first_name = 'Ruth' and last_name = 'Cadbury');

/* 7. Including Extras. Calculate the total bill for booking 5128
including extras. */
select
  b.booking_id,
  (amount * nights + extra_amount) as total
from booking b
  join rate r on b.room_type_requested = r.room_type and b.occupants = r.occupancy
  join (select
          e.booking_id,
          sum(amount) as extra_amount
        from extra e
        where e.booking_id = 5128
        group by e.booking_id
       ) ea on ea.booking_id = b.booking_id
where b.booking_id = 5128;
/* My script returned different answer to the expected output. The
amount of staying for two nights already exceeded the expected
output of 118.56. */


/* 8. Edinburgh Residents. For every guest who has the word “Edinburgh”
in their address show the total number of nights booked. Be sure to
include 0 for those guests who have never had a booking. Show
last name, first name, address and number of nights. Order by last
name then first name.  */

select
  last_name,
  first_name,
  address,
  sum(case when nights is null
    then 0
      else nights end) as total_nights
from guest
  left join booking b on guest.id = b.guest_id
where address like '%Edinburgh%'
group by first_name, last_name, address
order by last_name, first_name;

/* 9. Show the number of people arriving. For each day of the week
beginning 2016-11-25 show the number of people who are arriving
that day. */

select
  booking_date,
  sum(occupants) as arrivals
from booking
where booking_date >= '2016-11-25' and booking_date < '2016-11-25' :: date + interval '7 days'
group by booking_date
order by booking_date;

/* This output disagrees with the expected result on the website.
In the expected output, it seems they have counted the lines. In
my case, I have summed up the number of occupants as total arrivals*/


/* 10. How many guests? Show the number of guests in the hotel on
the night of 2016-11-21. Include all those who checked in that
day or before but not those who have check out on that day or
before. */

select sum(occupants) as no_guests
from booking
where booking_date <= '2016-11-21' and booking_date + nights * interval '1 days' > '2016-11-21';
