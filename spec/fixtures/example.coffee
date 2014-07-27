add = (x, y)->
	x + y
console.log add(1, 2)

times = (a = 1, b = 2) -> a * b
times()

sum = (nums...) ->
	result = 0
	nums.forEach (n) -> result += n
	result
sum(1, 2, 3)

add(1, 2)