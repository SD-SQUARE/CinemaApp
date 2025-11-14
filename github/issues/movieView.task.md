## Task Summary

- Build Movie View page.
- For Customer.
  - Display Title, description, image, price, list of available show times seat grid.
  - checkout section display total cost and seats per show times.
  - no 2 users allowed to book same seat at same show time.
  - real time booking is enabled.
- For Vendor.
  - Display Title, description, image, price, list of available show times seat grid.
  - real time booking is enabled.

## Details

- **Objective:** view movie and buy ticket for customers.  
- **Specifications:**
  - use channel from supabase to listen to changes.
  - use rpc from supabase with defined function "delete_movie" to delete movie.
- **Steps:**
  - fetch data and display them.
  - select show time.
  - listen to changes on reservation table for seats booked.
  - for customers.
    - allow un/reserve seat on click
    - allow checkout the reserved seats.
  - for vendor.
    - allow edit or delete from the 3 dots in app bar.

## Associated Story/Epic

- MovieList To Be Finished

## Acceptance Criteria

- view movies.
- view reservations in realtime.  
- for customer.
  - un/reserve seat.
  - checkout.
- for vendor.
  - delete
  - edit

## Dependencies

- NONE.  

## Attachments

- Customer Screen.
  `<img src="../../design/screens/customer_screens.png" alt='Customer screen'>`
- Vendor Screen.
  `<img src="../../design/screens/vendor_screens.png" alt='Vendor screen'>`

## Estimated Time

- 6 Hr  

## Notes/Additional Information

- NONE
