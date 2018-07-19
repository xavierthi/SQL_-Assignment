#1a. Display the first and last names of all actors from the table actor.

select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select concat(first_name," ",last_name) as Actor_Name from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor
where first_name= "JOE";

#2b. Find all actors whose last name contain the letters GEN:

select actor_id, first_name, last_name 
from actor
where last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:


select actor_id, first_name, last_name 
from actor
where last_name like '%LI%'
order by 3,2;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id , country from country
where country in ("Afghanistan", "Bangladesh", "China");

#  3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
 ADD COLUMN middle_name 
 VARCHAR(45) NULL AFTER first_name;
 
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name.


select last_name, count(*) as 'Count'
from actor 
group by 1;

 #4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) AS `Count`
FROM actor
GROUP BY 1
HAVING Count > 2
order by 2 desc;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor 
SET first_name= 'HARPO'
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

select actor_id, first_name, last_name from actor 
where first_name = 'HARPO';
UPDATE actor 
SET first_name= 'GROUCHO'
WHERE actor_id= 172;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESCRIBE sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:


select s.first_name, s.last_name, ad.address from staff s
join address ad on ad.address_id = s.address_id;

 #6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select p.staff_id, sum(p.amount) ,concat(s.first_name," ", s.last_name) as "Name" from payment p
join staff s on s.staff_id = p.staff_id 
group by 1,3;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select count(fa.actor_id), f.title from film_actor fa
inner join film f on f.film_id = fa.film_id
group by 2
order by 1 desc;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(*) from inventory i
where i.film_id in
(
select  f.film_id from film f
where f.title = "Hunchback Impossible");

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name: 
SELECT last_name, first_name, SUM(amount) AS Total_paid FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
 GROUP BY 1,2
 ORDER BY 1 ASC;
 
 
# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
 

SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(SELECT language_id FROM language where name='English');
 

#7b. Use subqueries to display all actors who appear in the film Alone Trip.


select concat(first_name, " ", last_name) as "Name" from actor
where actor_id in (
select actor_id from film_actor
where film_id in 
(
select film_id from film 
where title = "Alone Trip")
);

#7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email from customer where 
address_id in(	
select address_id from address
	where city_id in( 
	select city_id from city 
		where country_id in(
			select country_id from country
				where country = "Canada")
)
);

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select title, description from film
where film_id in (
select film_id from film_category
where category_id in(
select category_id from category
where name = "family")
);

#7e. Display the most frequently rented movies in descending order.

select * from (select f.title , count(*) as count_rented
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
group by 1
order by 2 desc) as t;

 #7f. Write a query to display how much business, in dollars, each store brought in. 

select st.store_id, sum(p.amount) from store st
Inner join staff s on s.store_id = st.store_id
Inner join payment p on p.staff_id = s.staff_id
group by 1;


#7g. Write a query to display for each store its store ID, city, and country.

select s.store_ID, c.city, co.country from store s
join address ad on ad.address_id =s.address_id
join city c on c.city_id = ad.city_id
join country co on co.country_id = c.country_Id;


#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 
Create view Top_5 as 
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

#8b. How would you display the view that you created in 8a?
 SELECT * FROM Top_5;
 
 -- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. DROP VIEW top_five_genres;
 
 drop view top_5;
 
 
 
 
 








