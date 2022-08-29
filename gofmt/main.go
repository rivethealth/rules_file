package main

import (
	"go/format"
	"io/ioutil"
	"log"
	"os"
)

func main() {
	lines, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Printf("Failed to read from stdin: %v", err)
		return
	} 

	fmt, err := format.Source(lines)
	if err != nil {
		log.Printf("Failed to format: %v", err)
		return
	} 
	os.Stdout.Write(fmt)
}