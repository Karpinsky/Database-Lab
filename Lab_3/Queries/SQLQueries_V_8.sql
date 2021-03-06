﻿USE Labor_SQL;
GO

IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'TF' AND name = 'SO_SPLIT_STRING')
BEGIN
    DROP FUNCTION [dbo].[SO_SPLIT_STRING]
END
GO

CREATE FUNCTION [dbo].[SO_SPLIT_STRING]
(
	@string NVARCHAR(MAX),
	@delimiter CHAR(1)
)
RETURNS @output TABLE(splitdata NVARCHAR(MAX))
BEGIN
	SET @string += @delimiter

	DECLARE @start INT, @end INT
	SELECT @start = 1, @end = CHARINDEX(@delimiter, @string)
	WHILE @start < LEN(@string) + 1
		BEGIN
		IF @end = 0
			SET @end = LEN(@string) + 1

		INSERT INTO @output (splitdata)
		VALUES (SUBSTRING(@string, @start, @end - @start))
		SET @start = @end + 1
		SET @end = CHARINDEX(@delimiter, @string, @start)

		END
	RETURN
END
GO

IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'TF' AND name = 'SO_GET_STRING_PART')
BEGIN
    DROP FUNCTION [dbo].[SO_GET_STRING_PART]
END
GO

CREATE FUNCTION [dbo].[SO_GET_STRING_PART]
(
	@string NVARCHAR(MAX),
	@delimiter CHAR(1),
	@part_index INT
)
RETURNS @output TABLE(string_part NVARCHAR(MAX))
BEGIN
	SET @string += @delimiter

	DECLARE @start INT, @end INT, @current_index INT
	SELECT @start = 1, @end = CHARINDEX(@delimiter, @string), @current_index = 0
	WHILE @start < LEN(@string) + 1 AND @current_index != @part_index
		BEGIN
		IF @end = 0
			SET @end = LEN(@string) + 1

		SET @start = @end + 1
		SET @end = CHARINDEX(@delimiter, @string, @start)
		SET @current_index += 1

		END

	INSERT INTO @output (string_part)
	VALUES (SUBSTRING(@string, @start, @end - @start))
	
	RETURN
END
GO

IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'TF' AND name = 'SO_CUT_STRING_TO')
BEGIN
    DROP FUNCTION [dbo].[SO_CUT_STRING_TO]
END
GO

CREATE FUNCTION [dbo].[SO_CUT_STRING_TO]
(
	@string NVARCHAR(MAX),
	@delimiter CHAR(1),
	@part_index INT
)
RETURNS @output TABLE(string_part NVARCHAR(MAX))
BEGIN
	DECLARE @start INT, @end INT, @current_index INT
	SELECT @start = 1, @end = CHARINDEX(@delimiter, @string), @current_index = 0
	WHILE @start < LEN(@string) + 1 AND @current_index != @part_index
		BEGIN
		IF @end = 0
			SET @end = LEN(@string) + 1

		SET @start = @end + 1
		SET @end = CHARINDEX(@delimiter, @string, @start)
		SET @current_index += 1

		END

	INSERT INTO @output (string_part)
	VALUES (SUBSTRING(@string, @start, LEN(@string)))
	
	RETURN
END
GO

/*
	1) БД «Кораблі».
	Перерахувати назви головних кораблів (із таблиці Ships). 
	Вивести: name, class. 
	Вихідні дані впорядкувати за зростанням за стовпцем name.
*/
SELECT [Ships].[name] AS ship_name, [Ships].[class] AS ship_class
FROM [Ships]
WHERE [Ships].name = [Ships].class
ORDER BY ship_name;

/*
	2) БД «Аеропорт».
	Вивести прізвища пасажирів (друге слово в стовпці name), що починаються на літеру 'С'.
*/
-- CASE 1 - Not giving the correct data because of middle or tripple names in name field. Look at CASE 2 for more correct data.
WITH SplitNameData AS
(
	SELECT ROW_NUMBER() OVER(ORDER BY [Passenger].[name] DESC) AS id, [passenger_name_split].splitdata
	FROM [Passenger]
	CROSS APPLY (SELECT * FROM [SO_SPLIT_STRING]([Passenger].[name], ' ')) AS [passenger_name_split]
)
SELECT [splitdata]
FROM [SplitNameData]
WHERE [id] % 2 = 0 AND [splitdata] LIKE 'C%';

-- CASE 2 - Loses some last names due to midle or tripple name because gets 2 word in column, though data is correct, but not full. Look at CASE 3 for more correct data.
SELECT [passenger_last_name].[string_part]
FROM [Passenger]
CROSS APPLY (SELECT * FROM [SO_GET_STRING_PART]([Passenger].[name], ' ', 1)) AS [passenger_last_name]
WHERE [passenger_last_name].[string_part] LIKE 'C%'
GO

-- CASE 3 - Gives the most precise and correct data.
SELECT [passenger_full_last_name].[string_part]
FROM [Passenger]
CROSS APPLY (SELECT * FROM [SO_CUT_STRING_TO]([Passenger].[name], ' ', 1)) AS [passenger_full_last_name]
WHERE [passenger_full_last_name].[string_part] LIKE 'C%'
GO

/*
	3) БД «Комп. фірма». 
	Знайдіть пари моделей ноутбуків, що мають однакові об’єми жорстких дисків та RAM (таблиця Laptop). 
	У результаті кожна пара виводиться лише один раз. 
	Порядок виведення: модель із більшим номером, модель із меншим номером, об’єм диску та RAM.
*/
SELECT DISTINCT ((CAST([LP_one].[model] AS INT) + CAST([LP_two].[model] AS INT)) + ABS(CAST([LP_one].[model] AS INT) - CAST([LP_two].[model] AS INT))) / 2 AS [model_one], 
	((CAST([LP_one].[model] AS INT) + CAST([LP_two].[model] AS INT)) - ABS(CAST([LP_one].[model] AS INT) - CAST([LP_two].[model] AS INT))) / 2 AS [model_two],
	[LP_one].hd,
	[LP_one].ram
FROM [Laptop] AS LP_one
JOIN [Laptop] AS LP_two
ON [LP_one].ram = [LP_two].ram AND [LP_one].hd = [LP_two].hd AND [LP_one].code != [LP_two].code;

/*
	4) БД «Комп. фірма». 
	Знайдіть виробників, що випускають ПК, але не ноутбуки (використати ключове слово ANY). 
	Виведіть: maker.
*/
SELECT [PR].[maker]
FROM [Product] AS [PR]
WHERE NOT 'Laptop' = ANY(SELECT [Product].[type] FROM [Product] WHERE [Product].[maker] = [PR].[maker])
	AND 'PC' = ANY(SELECT [Product].[type] FROM [Product] WHERE [Product].[maker] = [PR].[maker])
GROUP BY [PR].[maker];

/*
	5) БД «Комп. фірма». 
	Знайдіть виробників принтерів, що випускають ПК із найменшим об’ємом RAM. 
	Виведіть: maker.
*/
DECLARE @PCMinRam INT;
SELECT @PCMinRam = MIN([PC].ram) FROM [PC];

DECLARE @PrinterMakers TABLE (maker VARCHAR(1) UNIQUE);
INSERT INTO @PrinterMakers
SELECT [Product].[maker]
FROM [Product]
JOIN [Printer]
ON [Product].[model] = [Printer].[model]
GROUP BY [Product].[maker]

SELECT DISTINCT [Product].[maker]
FROM [Product]
JOIN [PC]
ON [Product].[model] = [PC].[model] AND [PC].[ram] = @PCMinRam AND [Product].[maker] IN (SELECT * FROM @PrinterMakers);

/*
	6) БД «Аеропорт».
	Вивести дані для таблиці Trip з об’єднаними значеннями двох стовпців: town_from та town_to, 
	з додатковими коментарями типу: 'from Rostov to Paris'.
*/
SELECT CONCAT([town_from], ' ', [town_to]) AS [trip_road], CONCAT('from ', [town_from], ' to ', [town_to]) AS [comment]
FROM [Trip];

/*
	7) БД «Комп. фірма». 
	Знайти моделі та ціни ПК, вартість яких перевищує мінімальну вартість ноутбуків. 
	Вивести: model, price.
*/
DECLARE @LaptopMinValue INT;
SELECT @LaptopMinValue = MIN([price]) FROM [Laptop];

SELECT [model], [price]
FROM [PC]
WHERE [price] > @LaptopMinValue;

/*
	8) БД «Комп. фірма». 
	Знайдіть виробників, які б випускали ПК із мінімальною швидкістю не менше 500 МГц. 
	Вивести: maker, мінімальна швидкість. 
	(Підказка: використовувати підзапити в якості обчислювальних стовпців)
*/
SELECT [prt].[maker], MIN([pc].[speed]) AS min_speed
FROM [PC] AS [pc]
JOIN [Product] AS [prt]
ON [pc].[model] = [prt].[model]
GROUP BY [maker]
HAVING MIN([pc].[speed]) >= 500;


/*
	9) БД «Фірма прий. вторсировини». 
	Визначіть лідера за сумою виплат у змаганні між кожною парою пунктів 
	з однаковими номерами із двох різних таблиць – Outcome та Outcome_o – на кожний день, 
	коли здійснювався прийом вторинної сировини хоча б на одному з них. 
	Вивести: Номер пункту, дата, текст: 
	– 'once a day', якщо сума виплат є більшою у фірми зі звітністю один раз на день; 
	– 'more than once a day', якщо – у фірми зі звітністю декілька разів на день; 
	– 'both', якщо сума виплат є однаковою.  
	(Підказка: для з’єднання таблиць використовувати повне зовнішнє з’єднання, 
	а для перевірки умов оператор CASE; 
	для пунктів, що не мають у певні дні видачі грошей – необхідно обробляти NULL - 
	значення за допомогою перевірки умови IS [NOT] NULL)
*/
SELECT
	CASE
		WHEN [any_outcome].[point] IS NULL OR [day_outcome].[point] IS NULL
			THEN -1
		ELSE [any_outcome].[point] 
	END AS [point], 
	[any_outcome].[date] AS [date],
	CASE 
		WHEN [day_outcome].[out] > [any_outcome].[out]
			THEN 'once a day'
		WHEN [day_outcome].[out] < [any_outcome].[out]
			THEN 'more than once a day'
		WHEN [day_outcome].[out] IS NULL OR [any_outcome].[out] IS NULL
			THEN 'No match'
		ELSE 'both'
	END AS [text]
FROM [Outcome_o] AS [day_outcome]
FULL OUTER JOIN (SELECT [point], [date], SUM([out]) AS [out] FROM [Outcome] GROUP BY [point], [date]) AS [any_outcome]
ON [any_outcome].[date] = [day_outcome].[date] AND [any_outcome].[point] = [day_outcome].[point]
ORDER BY [date] DESC;

/*
	10) БД «Комп. фірма».
	Для кожної моделі продукції з усієї БД виведіть її середню ціну. 
	Вивести: type, model, середня ціна. 
	(Підказка: використовувати оператор UNION)
*/
SELECT 'PC' AS [type], AVG([price]) AS [avg_price]
FROM [PC]
UNION
SELECT 'Laptop' AS [type], AVG([price]) AS [avg_price]
FROM [Laptop]
UNION
SELECT 'Printer' AS [type], AVG([price]) AS [avg_price]
FROM [Printer];