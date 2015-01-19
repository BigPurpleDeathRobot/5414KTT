// Go 1.2
// go run helloworld_go.go

package main

import (
    . "fmt"     // Using '.' to avoid prefixing functions with their package names
                //   This is probably not a good idea for large projects...
    "runtime"
    "time"
)

var i = make(chan int, 1)

func someGoroutine1() {
    Println("Hello from a goroutine1!")
    for j:=1; j<=1000000; j++{
    	local := <-i
    	local++
    	i <- local
    }
}

func someGoroutine2() {
    Println("Hello from a goroutine2!")
    for j:=1; j<=1000000; j++{
    	local := <-i
    	local --
    	i <- local
    }
}

func main() {
    runtime.GOMAXPROCS(runtime.NumCPU())    // I guess this is a hint to what GOMAXPROCS does...
                                            // Try doing the exercise both with and without it!
    i <- 0
    
    go someGoroutine1()                      // This spawns someGoroutine() as a goroutine
    go someGoroutine2()

    // We have no way to wait for the completion of a goroutine (without additional syncronization of some sort)
    // We'll come back to using channels in Exercise 2. For now: Sleep.
    time.Sleep(100*time.Millisecond)
    Println("Hello from main!")
    Println(<-i)
}