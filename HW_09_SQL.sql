USE sakila;
-- 1a Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT Concat(upper(first_name), ' ', upper(last_name)) AS 'Actor Name' FROM actor;
SELECT Concat(upper(first_name), ' ', lower(last_name)) AS 'Actor Name' FROM actor;
SELECT Concat(lower(first_name), ' ', upper(last_name)) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor where first_name='Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor where last_name like '%LI%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country where country IN ('Afghanistan', 'Bangladesh', 'China')

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE `actor`
ADD COLUMN `description` BLOB NULL AFTER `last_update`;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE `actor` 
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT COUNT(*) as n, last_name 
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT COUNT(*) as n, last_name 
FROM actor 
GROUP BY last_name
Having n>1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT REPLACE ('GROUCHO', 'GROUCHO', 'HARPO')
FROM actor
WHERE first_name='GROUCHO' and last_name='WILLIAMS'

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
SELECT REPLACE ('HARPO', 'HARPO', 'GROUCHO')
FROM actor

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE address

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM staff;
SELECT * FROM address;

SELECT s.first_name, s.last_name, a.address
FROM staff s
LEFT JOIN address a
ON s.address_id=a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT * FROM payment;

SELECT s.first_name, s.last_name, SUM(p.amount) as 'total amount in August of 2005'
FROM staff s
LEFT JOIN payment p
ON s.staff_id=p.staff_id
Where p.payment_date like '%2005-08%'
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT f.title, COUNT(k.actor_id) as 'number of actors by film'
FROM film_actor k
RIGHT JOIN film f
ON k.film_id=f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT * FROM inventory;

SELECT b.title, COUNT(a.inventory_id) as 'copies in inventory system'
FROM inventory a
RIGHT JOIN film b
ON a.film_id=b.film_id
Where b.title like 'Hunchback Impossible'
GROUP BY b.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT * FROM customer;

SELECT c.first_name, c.last_name, SUM(p.amount) as 'total paid by each customer'
FROM payment p
LEFT JOIN customer c
ON p.customer_id=c.customer_id
GROUP BY c.customer_id
Order by c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM language;
SELECT * FROM film;

SELECT f.title, l.name
FROM language l
INNER JOIN film f
ON l.language_id=f.language_id
Where f.title LIKE ('K%') or f.title LIKE ('Q%') and l.name IN ('English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
    SELECT actor_id FROM film_actor 
    WHERE film_id = (
        SELECT film_id FROM film WHERE title = 'Alone Trip'
    )
)

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer a
JOIN address b on a.address_id = b.address_id
JOIN city c on b.city_id = c.city_id
JOIN country d on c.country_id = d.country_id
WHERE d.country = 'Canada'

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title, description, name as 'type'
FROM film a
JOIN film_category b on a.film_id = b.film_id
JOIN category c on b.category_id = c.category_id
WHERE c.name = 'Family'

-- 7e. Display the most frequently rented movies in descending order.
SELECT c.title, COUNT(a.inventory_id) as rental_count
FROM rental a
JOIN inventory b on a.inventory_id = b.inventory_id
JOIN film c on b.film_id = c.film_id
GROUP BY c.title
ORDER BY rental_count desc

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store;

SELECT c.store_id as StoreID, SUM(a.amount)
FROM payment a
JOIN staff b on a.staff_id = b.staff_id
JOIN store c on b.store_id = c.store_id
GROUP BY c.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, c.city, d.country
FROM store a 
JOIN address b on a.address_id = b.address_id
JOIN city c on b.city_id = c.city_id
JOIN country d on c.country_id = d.country_id

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT e.name as filmCategory, SUM(a.amount) as gRevenue
FROM payment a
JOIN rental b on a.rental_id = b.rental_id
JOIN inventory c on b.inventory_id = c.inventory_id
JOIN film_category d on c.film_id = d.film_id
JOIN category e on d.category_id = e.category_id
GROUP BY filmcategory
ORDER BY grevenue DESC limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
SELECT a.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category a
JOIN film_category b ON (a.category_id=b.category_id)
JOIN inventory i ON (b.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY a.name ORDER BY Gross DESC LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
CREATE VIEW Top_Five AS
SELECT a.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category a
JOIN film_category b ON (a.category_id=b.category_id)
JOIN inventory i ON (b.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY a.name ORDER BY Gross DESC LIMIT 5;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_Five