---
layout: post
title: 'Regular expressions: non-capturing groups'
date: 2017-10-05
---

If you never studied thoroughly regular expressions but, like me, learned it bit by bit as you needed it, you may not know *non-capturing groups*. This feature may be useful at least when some quantifier (?, \*, ...) applies to a subset of the expression but you don't want this subset to be captured. Let's develop this. Consider a process producing this output:

	(2, 5)
	(5, 12)
	(14, 43)

And imagine you have to get the numbers between parentheses.

We could start by creating a regular expression that matches each line (code in Javascript):

	var data = [
		"(2, 5)",
		"(5, 12)",
		"(14, 43)"
	];
	var regexp = /\(\d+,\s*\d+\)/;
	data.forEach(function (line) { 
		console.log(line + " -> " + regexp.test(line));
	});

Which would output:

	(2, 5) -> true
	(5, 12) -> true
	(14, 43) -> true

The following diagram(?) explains the regular expression:

	\( \d+ , \s \d+ \)
	^  ^   ^ ^  ^   ^
	|  |   | |  |   closing parenthesis
	|  |   | |  one or more digits
	|  |   | espace
	|  |   coma
	|  one or more digits
	Open parenthesis

If we want to get the numbers we need to capture them. And this is done in the regular expression by using capture groups, which syntactically requires to wrap the part we are interested in between parentheses:

	\( (\d+) , \s (\d+) \)
	^  ^     ^ ^  ^     ^
	|  |     | |  |     closing parenthesis
	|  |     | |  capture one or mor digits
	|  |     | espace
	|  |     coma
	|  capture one or more digits
	Open parenthesis

The Javascript code has to change as well in order to retrieve the two captured groups. Instead of testing the regular expression it obtains a *match* array with the captured groups:

	var data = [
		"(2, 5)",
		"(5, 12)",
		"(14, 43)"
	];
	var regexp = /\((\d+),\s*(\d+)\)/;
	data.forEach(function (line) { 
		var match = regexp.exec(line);
		console.log(line + " -> " + match[1] + "," + match[2]);
	});

producing the following output:

	(2, 5) -> 2,5
	(5, 12) -> 5,12
	(14, 43) -> 14,43

Now consider that numbers have an optional decimal part, like 4.124. The process output could be this:

	(2, 5)
	(5.31, 12)
	(14, 43.12)

The regular expression has to deal now with cases where the *dot* **and** one or more digits appear. Somewhat it has to check that either the *dot* (\\.) and one or more digits (\d+) appear, or none of them do. In order to treat *\\.\d+* as a whole and be made optional it is possible to wrap the expression between parentheses and add the optional quantifier thus: *(\\.\d+)?*. Instead of:

    var regexp = /\((\d+),\s*(\d+)\)/;

The regular expression should be (differences underlined):

	var regexp = /\((\d+(\.\d+)?),\s*(\d+(\.\d+)?)\)/;
                        ________         ________

But this syntax, putting things between parentheses, is the one of capturing groups and it would add new groups to the result. The output of the script would show clearly that the parentheses used for the optional decimal part are creating new capturing groups and messing with what the code expects (two capturing groups, one for each number):

	(2, 5) -> 2,undefined
	(5.31, 12) -> 5.31,.31
	(14, 43.12) -> 14,undefined

We arrive to the point: the non capturing groups. With the syntax *(?:group)* it is possible to use parentheses to group elements in a regular expression without creating a capturing group. We can create a group for the optional decimal part and use the non capturing syntax to avoid capturing it:

	\( (\d+ (?: \.\d+ ) ? ) , ...
	        -----------
	^  ^    ^   ^     ^ ^ ^ ^ ^
	|  |    |   |     | | | | rest of the regular expression where the same solution is repeated for the second number
	|  |    |   |     | | | coma
	|  |    |   |     | | close capturing group, including the optional decimal part group
	|  |    |   |     | decimal part non capturing group is optional
	|  |    |   |     close not capturing group
	|  |    |   decimal part
	|  |    open non capturing group
	|  capture one or more digits with optional decimal part
	Open parenthesis

The code, containing the final regular expression, would be this:

	var data = [
		"(2, 5)",
		"(5.31, 12)",
		"(14, 43.12)"
	];
	var regexp = /\((\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?)\)/;
	data.forEach(function (line) { 
		var match = regexp.exec(line);
		console.log(line + " -> " + match[1] + "," + match[2]);
	});

And the output, as expected:

	(2, 5) -> 2,5
	(5.31, 12) -> 5.31,12
	(14, 43.12) -> 14,43.12
