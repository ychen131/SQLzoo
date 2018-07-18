/* Medium Difficulty Question 6 - 10 */

/* 6. Ruth Cadbury. Show the total amount payable by guest Ruth
Cadbury for her room bookings. You should JOIN to the rate table
using room_type_requested and occupants. */

select sum(amount*nights) as amount_to_pay
from booking b join rate r on b.room_type_requested = r.room_type and b.occupants = r.occupancy
where guest_id = (select id
                  from guest
                  where first_name = 'Ruth' and last_name = 'Cadbury');

/* 7. Including Extras. Calculate the total bill for booking 5128 including extras. */


