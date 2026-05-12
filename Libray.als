module LibraryManagementSystem

//------------------------------------
// SIGNATURES
//------------------------------------

sig Book {}

sig Student {}

sig Fine {
    student : one Student,
    amount : one Int
}

//------------------------------------
// SYSTEM STATE
//------------------------------------

sig LibrarySystem {
    books : set Book,
    students : set Student,
    // Nutze Relationen direkt in der Signatur
    issuedBooks : Book -> lone Student,
    fines : set Fine
}

//------------------------------------
// DERIVED RELATIONS
//------------------------------------

// Ausgeliehene Bücher
fun issued(ls : LibrarySystem) : set Book {
    ls.issuedBooks.Student
}

// Verfügbare Bücher
fun availableBooks(ls : LibrarySystem) : set Book {
    ls.books - issued[ls]
}

//------------------------------------
// FACTS
//------------------------------------

// Nur Bücher aus dem Bestand können verliehen werden
fact IssuedBooksExist {
    all ls : LibrarySystem |
        issued[ls] in ls.books
}

// Nur registrierte Studenten können Bücher leihen
fact RegisteredStudentsOnly {
    all ls : LibrarySystem |
        // Der Wertebereich (range) von issuedBooks muss in ls.students liegen
        Book.(ls.issuedBooks) in ls.students
}

//------------------------------------
// OPERATIONS
//------------------------------------

pred BorrowBook(ls, ls2 : LibrarySystem, s : Student, b : Book) {
    s in ls.students
    b in availableBooks[ls]

    ls2.books = ls.books
    ls2.students = ls.students
    ls2.fines = ls.fines
    ls2.issuedBooks = ls.issuedBooks + (b -> s)
}

pred ReturnBook(ls, ls2 : LibrarySystem, s : Student, b : Book) {
    b -> s in ls.issuedBooks

    ls2.books = ls.books
    ls2.students = ls.students
    ls2.fines = ls.fines
    ls2.issuedBooks = ls.issuedBooks - (b -> s)
}

//------------------------------------
// ASSERTIONS
//------------------------------------

assert NoDuplicateIssue {
    all ls : LibrarySystem |
        all b : Book | lone ls.issuedBooks[b]
}

assert IssuedBooksNotAvailable {
    all ls : LibrarySystem |
        no (availableBooks[ls] & issued[ls])
}

// Korrigierte Assertion
assert OnlyRegisteredStudentsBorrow {
    all ls : LibrarySystem |
        // Nutzt Join, um alle Studenten zu finden, die ein Buch haben
        Book.(ls.issuedBooks) in ls.students
}

//------------------------------------
// CHECKS
//------------------------------------

check NoDuplicateIssue for 5
check IssuedBooksNotAvailable for 5
check OnlyRegisteredStudentsBorrow for 5
