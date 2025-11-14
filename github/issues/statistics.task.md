## Task Summary

- Build statistics page with real time feature.
- display total tickets.
- display total cost.
- display all tickets.

## Details

- **Objective:** allow vendor to view bought tickets and total cost and number.  
- **Specifications:** 
  - use rpc from supabase with defined function `get_tickets_summary`.
  - use channel to listen to changes on ticket table to fetch updates.
  
- **Steps:**
  - on init fetch the summary and display it.
  - listen to changes on ticket table.
  
## Associated Story/Epic

- NONE.

## Acceptance Criteria

- sold tickets displayed with proper summary.
- real time update.
  
## Dependencies

- NONE.  

## Attachments

- Vendor Screen.
<img src="../../design/screens/vendor_screens.png" alt='Vendor screen'>

## Estimated Time

- 4 Hr  

## Notes/Additional Information

- NONE
