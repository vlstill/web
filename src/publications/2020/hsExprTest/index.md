---
title: Automatic Test Generation for Haskell Programming Assignments
autotitle: true
lang: en
vim: spelllang=en spell fo-=t tw=80 expandtab
---

*This is an accompanying page for the poster presentation at [ITiCSE 2020](https://iticse.acm.org/).*

## Abstract

Automatic testing of programming assignments is highly desirable as it can
provide fast feedback for the students and allows the teachers to teach
efficiently even in courses with many students.
However, writing tests for students' solutions can be tedious.
In this work, we present a novel approach to test generation for small Haskell
assignments.
Such assignments usually consist of one function (with the possibility to use
helper functions in its definition) that the students are supposed to program
according to a teacher's specification.
The teacher is not required to write tests for this function.
Instead, we make use of an example solution, which the teacher should have
to assess the difficulty of the assignment.
Using the example solution, and (if needed) a specification of input values for
the function, our tool can automatically generate randomized tests.
If these tests fail, the student is presented with a counterexample which
shows the input values, the expected output of the tested function and the
output computed by their solution.

## Artefacts

* the poster paper: [official version](https://doi.org/10.1145/3341525.3393972) and [author's version](http://www.vstill.eu/publications/2020/hsExprTest.pdf)
* [the actual poster](http://www.vstill.eu/publications/2020/hsExprTest/poster.pdf)
* [hsExprTest (the presented tool) is available at GitHub](https://github.com/vlstill/hsExprTest)
