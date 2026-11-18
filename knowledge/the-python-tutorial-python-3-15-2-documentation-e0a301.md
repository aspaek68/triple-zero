# The Python Tutorial — Python 3.15.2 documentation

- **Source**: https://docs.python.org/3/tutorial/index.html
- **Fetched**: 2026-11-18T14:25:22

**Python Tutorial**
================

**Overview**
------------

This tutorial is designed for programmers new to the Python language. It provides an informal introduction to the basic concepts and features of Python, including its syntax, data structures, and modules. The tutorial is not comprehensive, but it will give you a good idea of the language's flavor and style.

**Installing Python**
--------------------

The Python interpreter and standard library are freely available in source or binary form for all major platforms from the Python website: https://www.python.org/. You can also find distributions of and pointers to many free third-party Python modules, programs, and tools.

**Tutorial Structure**
--------------------

The tutorial is divided into several sections:

1. **Whetting Your Appetite**: Introduction to Python and its features.
2. **Using the Python Interpreter**: Invoking the interpreter, argument passing, and interactive mode.
3. **An Informal Introduction to Python**: Using Python as a calculator, first steps towards programming, and control flow tools.
4. **Data Structures**: Lists, tuples, sets, dictionaries, and loop techniques.
5. **Modules**: Executing modules as scripts, standard modules, and packages.
6. **Input and Output**: Fancier output formatting, reading and writing files, and input and output operations.
7. **Errors and Exceptions**: Handling syntax errors, exceptions, and user-defined exceptions.
8. **Classes**: Defining classes, inheritance, and private variables.
9. **Brief Tours of the Standard Library**: Introduction to the standard library, including operating system interface, file wildcards, and more.

**Key APIs and Concepts**
------------------------

* `dir()`: Returns a list of valid attributes for an object.
* `exec()`: Executes a Python expression.
* `input()`: Reads user input.
* `print()`: Prints output.
* `try`-`except`: Handles exceptions.
* `class`: Defines a class.
* `def`: Defines a function.
* `lambda`: Defines a small anonymous function.

**Example Code**
---------------

```python
# Basic print statement
print("Hello, World!")

# Variable assignment
x = 5

# Conditional statement
if x > 10:
    print("x is greater than 10")
else:
    print("x is less than or equal to 10")

# List comprehension
numbers = [1, 2, 3, 4, 5]
squared_numbers = [n**2 for n in numbers]
print(squared_numbers)
```

**Next Steps**
--------------

After completing this tutorial, you will be able to read and write Python modules and programs. You will also be ready to learn more about the various Python library modules described in the Python standard library.
