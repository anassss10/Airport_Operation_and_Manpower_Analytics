create database airport_operations;
USE airport_operations;

CREATE TABLE airport_flights (
    flight_id INT,
    flight_number VARCHAR(10),
    airline VARCHAR(50),
    terminal VARCHAR(5),
    scheduled_arrival DATETIME,
    scheduled_departure DATETIME,
    actual_arrival DATETIME,
    actual_departure DATETIME
);

SELECT COUNT(*) FROM airport_flights_30000;

DROP TABLE ground_handling_logs;

RENAME TABLE ground_handling_logs_90000 TO ground_handling_logs;

USE airport_operations;

CREATE TABLE staff_roster (
    staff_id INT,
    staff_name VARCHAR(100),
    role VARCHAR(50),
    shift_start DATETIME,
    shift_end DATETIME,
    terminal VARCHAR(5)
);

SELECT COUNT(*) FROM staff_roster;

CREATE TABLE ground_delay (
    flight_id INT,
    delay_minutes INT,
    delay_reason VARCHAR(100)
);

CREATE TABLE ground_handling_logs (
    log_id INT,
    flight_id INT,
    staff_id INT,
    task VARCHAR(100),
    task_start DATETIME,
    task_end DATETIME
);


SELECT COUNT(*) FROM airport_flights;
SELECT COUNT(*) FROM staff_roster;
SELECT COUNT(*) FROM ground_handling_logs;


SELECT 
    flight_id,
    TIMESTAMPDIFF(
        MINUTE,
        actual_arrival,
        actual_departure
    ) AS turnaround_time_minutes
FROM airport_flights;

DESCRIBE airport_flights;


DESCRIBE airport_flights;
DESCRIBE staff_roster;
DESCRIBE ground_handling_logs;

SELECT * FROM airport_flights LIMIT 5;
SELECT * FROM staff_roster LIMIT 5;
SELECT * FROM ground_handling_logs LIMIT 5;

SELECT AVG(turnaround_time_min) AS avg_tat
FROM airport_flights;


SELECT terminal, COUNT(*) AS delayed_flights
FROM airport_flights
WHERE delay_minutes > 15
GROUP BY terminal;

SELECT SUBSTRING(arrival_time, 1, 2) AS hour, COUNT(*) AS flights
FROM airport_flights
GROUP BY hour
ORDER BY flights DESC;


SELECT
    staff_id,
    SUM(
        TIMESTAMPDIFF(
            MINUTE,
            STR_TO_DATE(task_start,'%H:%i'),
            STR_TO_DATE(task_end,'%H:%i')
        )
    ) AS task_minutes
FROM ground_handling_logs
GROUP BY staff_id;



SELECT
    flight_id,
    terminal,
    aircraft_type,
    turnaround_time_min,
    delay_minutes
FROM airport_flights
WHERE turnaround_time_min > 60;


SELECT
    flight_id,
    task,
    staff_required,
    task_duration_min,
    (staff_required * task_duration_min) AS manpower_minutes
FROM ground_handling_logs;



SELECT
    flight_id,
    SUM(staff_required * task_duration_min) AS total_workload_minutes
FROM ground_handling_logs
GROUP BY flight_id;



SELECT
    f.flight_id,
    f.terminal,
    f.aircraft_type,
    f.turnaround_time_min,
    f.delay_minutes,
    g.total_workload_minutes
FROM airport_flights f
JOIN (
    SELECT
        flight_id,
        SUM(staff_required * task_duration_min) AS total_workload_minutes
    FROM ground_handling_logs
    GROUP BY flight_id
) g
ON f.flight_id = g.flight_id;



SELECT
    terminal,
    AVG(total_workload_minutes) AS avg_workload,
    AVG(delay_minutes) AS avg_delay
FROM (
    SELECT
        f.flight_id,
        f.terminal,
        f.delay_minutes,
        g.total_workload_minutes
    FROM airport_flights f
    JOIN (
        SELECT
            flight_id,
            SUM(staff_required * task_duration_min) AS total_workload_minutes
        FROM ground_handling_logs
        GROUP BY flight_id
    ) g
    ON f.flight_id = g.flight_id
) x
GROUP BY terminal;



SELECT
    staff_id,
    role,
    terminal,
    TIMESTAMPDIFF(
        MINUTE,
        STR_TO_DATE(shift_start,'%H:%i'),
        STR_TO_DATE(shift_end,'%H:%i')
    ) AS shift_minutes
FROM staff_roster;



SELECT
    terminal,
    SUM(
        TIMESTAMPDIFF(
            MINUTE,
            STR_TO_DATE(shift_start,'%H:%i'),
            STR_TO_DATE(shift_end,'%H:%i')
        )
    ) AS total_staff_capacity_minutes
FROM staff_roster
GROUP BY terminal;



SELECT
    f.terminal,
    SUM(g.staff_required * g.task_duration_min) AS workload_demand_minutes
FROM airport_flights f
JOIN ground_handling_logs g
ON f.flight_id = g.flight_id
GROUP BY f.terminal;



SELECT
    c.terminal,
    c.total_staff_capacity_minutes,
    d.workload_demand_minutes,
    (c.total_staff_capacity_minutes - d.workload_demand_minutes) AS surplus_or_deficit
FROM (
    SELECT
        terminal,
        SUM(
            TIMESTAMPDIFF(
                MINUTE,
                STR_TO_DATE(shift_start,'%H:%i'),
                STR_TO_DATE(shift_end,'%H:%i')
            )
        ) AS total_staff_capacity_minutes
    FROM staff_roster
    GROUP BY terminal
) c
JOIN (
    SELECT
        f.terminal,
        SUM(g.staff_required * g.task_duration_min) AS workload_demand_minutes
    FROM airport_flights f
    JOIN ground_handling_logs g
    ON f.flight_id = g.flight_id
    GROUP BY f.terminal
) d
ON c.terminal = d.terminal;





















