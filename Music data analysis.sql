/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;




/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;

/* Question set -3 Advance Level */

/* Question 1.
Find the best-selling artist (in terms of total revenue). 
Then, for that artist, return each customer’s name and how much they spent on that artist. */

with best_artist as (
select a.artist_id, a.name as artist_name,sum(il.unit_price*il.quantity) total_spend from artist as a
join album as al
on al.artist_id=a.artist_id
join track as t
on t.album_id=al.album_id
join invoice_line il
on il.track_id=t.track_id
group by 1 order by 3 desc limit 1)
select c.customer_id,c.first_name,c.last_name ,best_artist.artist_name,sum(il.unit_price*il.quantity)total_spend from customer as c
join invoice as i
on i.customer_id=c.customer_id
join invoice_line as il
on il.invoice_id=i.invoice_id
join track as t
on t.track_id=il.track_id
join album as al
on al.album_id=t.album_id
join best_artist
on best_artist.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc 

/* Question 2. We want to find out the most popular music genre for each country .We determine the most popular genre as the genre
with the highest amount purchase .Write a query that return each country along with the top genre.for the countries where the 
maximum number of purchases is share return all genres. */

with popular_genre as (
select c.country,g.name as genre_name,count(il.quantity)total_purchase,
row_number() over (partition by c.country order by count (il.quantity)desc) as rowno
from customer  as c
join invoice as i
on i.customer_id=c.customer_id
join invoice_line as il
on il.invoice_id=i.invoice_id
join track as t
on t.track_id=il.track_id
join genre as g
on g.genre_id=t.genre_id
group by 1,2 order by 3 desc )
select * from popular_genre where popular_genre.rowno<=1

/* Question 3. Write a query that determines the Customer that has spend the most on music for each Country.Write a query 
that return the Country along with the top customer and how much they spent.For countries where the amount spend in 
shared ,provide all customer who spend this amount . */
with cte as (
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total) total ,
row_number ()over(partition by i.billing_country order by sum(i.total) desc )as rowno 
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by 1,2,3,4 order by 4 desc
)
select * from cte where rowno<=1 