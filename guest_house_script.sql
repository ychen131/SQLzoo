/* Medium Problems 6 - 10 */ -------------------------------------------

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


/* Hard Problems 11 - 15 */ --------------------------------------

/* 11.Coincidence. Have two guests with the same surname ever
 stayed in the hotel on the evening? Show the last name and
 both first names. Do not include duplicates. */

select distinct
  g1.last_name,
  g1.first_name,
  g2.first_name
from
  booking b1, booking b2, guest g1, guest g2
where b1.guest_id = g1.id and b2.guest_id = g2.id
      and g1.last_name = g2.last_name and g1.first_name < g2.first_name
      and ((b1.booking_date, b1.booking_date + b1.nights * interval '1 days') overlaps
           (b2.booking_date, b2.booking_date + b2.nights * interval '1 days')
      )
order by last_name;


/*12. Check out per floor. The first digit of the room number
 indicates the floor – e.g. room 201 is on the 2nd floor. For
 each day of the week beginning 2016-11-14 show how many
 guests are checking out that day by floor number. Columns
 should be day (Monday, Tuesday ...), floor 1, floor 2,
 floor 3.*/

select to_char((booking_date + nights * interval '1 days'), 'Day') as check_out_date,
  count(case when substring(room_no::text, 1, 1)= '1' then occupants else null end) as floor1,
  count(case when substring(room_no::text, 1, 1)= '2' then occupants else null end) as floor2,
  count(case when substring(room_no::text, 1, 1)= '3' then occupants else null end) as floor3
from booking
where booking_date + nights * interval '1 days' in (select i
                                                    from calendar
                                                    where i >= '2016-11-14' and
                                                          i < '2016-11-14' :: date + interval '7 days')
group by booking_date + nights * interval '1 days';

/*Note that the question asked for number of people checked out
 on those dates, however, the output shows number of rooms
 checked out. This makes sense for the guest house owner. If total
 number of people are required, we just need to swap 'count with
 'sum' and 'null' with '0' */


/*13. Who is in 207? Who is in room 207 during the week beginning
21st Nov. Be sure to list those days when the room is empty. Show
the date and the last name. You may find the table calendar
useful for this query. */

select
  i,
  coalesce(last_name, 'Null') as last_name
from
  (select
     generate_series(booking_date, booking_date + (nights - 1) * interval '1 days', '1 days') as date_staying,
     nights,
     last_name
   from booking b
     join guest g on b.guest_id = g.id
   where room_no = 207 and booking_date <= '2016-11-21'::date + interval '7 days') as guest_b
  right join
  (select i
   from calendar
   where i >= '2016-11-21' and i < '2016-11-21' :: date + interval '7 days') dw
    on guest_b.date_staying = dw.i
order by i;


/*14. Double room for seven nights required. A customer wants
a double room for 7 consecutive nights as some time between
2016-11-03 and 2016-12-19. Show the date and room number
for the first such availabilities.*/



/*15.Gross income by week. Money is collected from guests
when they leave. For each Thursday in November show the
total amount of money collected from the previous Friday to
that day, inclusive. */