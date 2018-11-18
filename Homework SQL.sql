USE sakila;
SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name, ' ', last_name) as 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
--     What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country;
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
SELECT * FROM actor;

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
--     so create a column in the table `actor` named `description` and use the data type `BLOB`
SELECT * FROM actor;
ALTER TABLE actor ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
SELECT * FROM actor;
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT * FROM actor;
SELECT last_name, COUNT(*)  FROM actor  GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by 
--     at least two actors
SELECT * FROM actor;
SELECT last_name, COUNT(*) as 'name' FROM actor  GROUP BY last_name HAVING COUNT(*) >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT actor_id, first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

-- ***4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a 
--     single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

-- ***5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- SELECT * FROM address 
CREATE TABLE new_address AS
	SELECT address_id, address, address2, district, city_id, postal_code, phone, location, last_update
    FROM address;
SELECT * FROM new_address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
-- SELECT * FROM address
-- SELECT * FROM staff
SELECT staff.address_id, staff.first_name, staff.last_name, address.address 
FROM staff
INNER JOIN address ON
staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
-- SELECT * FROM staff
-- SELECT * FROM payment
SELECT staff.staff_id,
SUM(payment.amount) AS 'Sum of Payment'
FROM staff
JOIN payment USING (staff_id)
WHERE payment_date  BETWEEN '2005/08/01' AND '2005/08/31'
GROUP BY staff_id;

-- 6.c List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
-- SELECT * FROM film_actor
-- SELECT * FROM film
SELECT film.title, 
COUNT(film_actor.actor_id) AS NumberOfActors 
FROM film_actor
INNER JOIN film USING (film_id)
GROUP BY film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, 
COUNT(inventory.inventory_id) AS 'Number of Copies'
FROM film
INNER JOIN inventory
USING (film_id)
WHERE title = "Hunchback Impossible"
GROUP BY title;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters `K` and `Q` whose language is English.
SELECT film.title 
FROM film 
WHERE title LIKE 'K%' 
OR title LIKE 'Q%' 
AND language_id 
IN (SELECT language_id FROM language WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers Use joins to retrieve this information.  
SELECT first_name, last_name, email
FROM customer
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT title, description, rating FROM film_list
WHERE category = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(*) AS rental_count
FROM film
JOIN inventory USING(film_id)
JOIN rental USING(inventory_id)
GROUP BY film_id
HAVING rental_count > 10
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id);

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)
SELECT * FROM sales_by_film_category
ORDER BY total_sales DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP view if exists Top_five_genres;
CREATE view Top_five_genres (category, total_sales) AS
SELECT * FROM sales_by_film_category
ORDER BY total_sales desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_five_genres;
