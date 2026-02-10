-- Task-10 List Employees with Their Branch Manager's Name and their branch details:
select 
e1.*,
b.branch_id,
e2.emp_name as manager
from employees e1
join branch b on b.branch_id=e1.branch_id 
join employees e2 on b.manager_id=e2.emp_id
--------------------------------------------
--Task 12: Retrieve the List of Books Not Yet Returned
select distinct ist.issued_book_name from issued_status ist
left join return_status rst on rst.issued_id=ist.issued_id
where rst.return_id is null
select * from return_status
--------------------------------------
------------------------------------
select * from issued_status

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');

SELECT * FROM return_status;
---------------------------------------------
SELECT * FROM return_status;
SELECT * FROM members;
SELECT * FROM books;
SELECT * FROM issued_status;

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.
select 
	m.member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	--rst.return_date
	current_date-ist.issued_date as due_days
from issued_status as ist
join books b on b.isbn=ist.issued_book_isbn
join members m on m.member_id=ist.issued_member_id
left join return_status rst on ist.issued_id=rst.issued_id
where rst.return_date is null
	and current_date-ist.issued_date >50
order by 1
---------------------------------------------------------
--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned
--(based on entries in the return_status table).
select * from books
select * from return_status
----------------------------------
/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books
issued, the number of books returned, and the total revenue generated from book rentals.
*/

select 
	b.branch_id,
	b.manager_id,
	extract(year from ist.issued_date) as year_consider,
	count(ist.issued_id) as total_book_issued,
	count(rst.return_id) as total_book_return,
	sum(bk.rental_price) as total_revenue
from issued_status as ist
join employees as e on ist.issued_emp_id=e.emp_id
join books as bk on ist.issued_book_isbn=bk.isbn
left join return_status as rst on ist.issued_id=rst.issued_id
join branch as b on e.branch_id=b.branch_id
group by 1,2,3--extract(year from ist.issued_date);
--order by 3;
having extract(year from ist.issued_date)='2026';

------------------------------------------------------------
/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months.
*/
create table active_members
as
select * from members
where member_id in (
			select distinct issued_member_id from issued_status
				where issued_date >= current_date - interval '2 month')
--------------------------------------------------------------
/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch
*/

select 
	e.emp_name,
	e.branch_id,
	count(bk.isbn) as no_books 
from issued_status ist 
join employees e on ist.issued_emp_id=e.emp_id
join books bk on ist.issued_book_isbn=bk.isbn
group by 1,2
order by 3 desc limit 3
------------------------------------------------------
/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status
"damaged" in the books table. Display the member name, book title, 
and the number of times they've issued damaged books.
*/
-----------------------------------------------------
/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the 
status of books in a library system. Description: Write a stored procedure that updates 
the status of a book in the library based on its issuance. The procedure should function
as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table 
should be updated to 'no'. If the book is not available (status = 'no'),
the procedure should return an error message indicating that the book is
currently not available.*/

select * from books
select * from issued_status

create or replace procedure issued_book(p_issued_id varchar(10),p_issued_member varchar(20),
p_issued_book_isbn varchar(20),p_issued_emp_id varchar(10))
language plpgsql
as $$
declare
	v_status varchar(10);
begin
	select status 
	into v_status
	from books
	where isbn=p_issued_book_isbn;
	if v_status='yes' then 
		insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		values(p_issued_id,p_issued_member,current_date,p_issued_book_isbn,p_issued_emp_id);
		raise notice 'successful to add book isbn: %',p_issued_book_isbn;
		update books
			set status='no'
			where isbn=p_issued_book_isbn;
	else
	raise notice 'SORRY to add book isbn: %',p_issued_book_isbn;
	end if;
end;
$$

---Testing
--isbn="978-0-553-29698-2" yes   issued_id=IS155 member_id=C106 emp_id=E104
--isbn="978-0-7432-7357-1" no  issued_id=156 member_id=C106 emp_id=104

call issued_book('IS155','C106','978-0-553-29698-2','E104');

call issued_book('IS155','C106','978-0-553-29698-2','E104');
--------------------------------------------------------------
