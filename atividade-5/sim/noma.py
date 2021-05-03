import sys
import resource

import itertools
from random import random

def main():
	J = 10 # Max value for my machine: 10

	G = 10
	g = [G*random() for _ in range(J)]

	# b_{p, i, n}
	# Apenas uma permutação deve ser escolhida
	# 

	# permutations = list(itertools.permutations(range(1, J+1)))

# https://stackoverflow.com/questions/41105733/limit-ram-usage-to-python-program
def memory_limit():
	soft, hard = resource.getrlimit(resource.RLIMIT_AS)
	resource.setrlimit(resource.RLIMIT_AS, (int(get_memory() * 1024 / 2), hard))

def get_memory():
	with open('/proc/meminfo', 'r') as mem:
		free_memory = 0
		for i in mem:
			sline = i.split()
			if str(sline[0]) in ('MemFree:', 'Buffers:', 'Cached:'):
				free_memory += int(sline[1])

	return free_memory

if __name__ == '__main__':
	memory_limit() # Limitates maximun memory usage to half
	try:
		main()
	except MemoryError:
		sys.stderr.write('\n\nERROR: Memory Exception\n')
		sys.exit(1)