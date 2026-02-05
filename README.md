# APLLIB
A program development application library for the IBM i environment

This is a work in process. It is really only intended for me, but others may
use it if they find it helpful. - Tim Tognazzini

The package includes a list of useful tools. Some of the major groups are listed
below.

- **The SQL Command** - A command that acts as an SQL query manager, as well as 
a command line tool that can convert the output of an SQL statement to Excel, 
CSV, or XML and facilitate sending it via email. It has its own documentation.

- **Shortcut Commands** - A bunch of commands that make developing on the IBM i 
easier. Some are just shortcuts like C = Call and WO = WRKOBJ. Others allow for
options that did not exist on the IBM. For example, the DSM command will 
display a source member in SEU, it will figure out which library the source 
member is in as well. Information about the commands can be found in 
documentation for the APLLIB project.

- **Programming Development Tools** - These tools consist of a dictionary
system that is used in the file master system to make a consistent database as
well as a program master system and templating environment that makes writing
interactive RPG programs a breeze. Documentation for this is in a separate 
document.

# Prerequisites
The package is pretty self contained with the exception of the #$XLSX project
used to create pretty Excel files in RPG. At some point I will integrate it 
into this project, but I need to bring it up the current coding standards
first.

# Installation Instructions

TODO

## Installing from Binaries

TODO

## Installing form Source

TODO

# The Story of APLLIB

The APLLIB project came as the result of a set of events that happened 
throughout my programming career. There are a lot developers that helped 
influence its development. Some are listed below. 

I started my career working for Computer Software Solutions (CSS) in Tulsa, Ok.
I worked there for nearly 20 years. In that time, I modified an existing ERP 
package to fit the needs of clients in many niche industries.

The large amount of coding required the creation of many tools. At CSS I 
inherited good development techniques since we had many clients to 
support. I learned to always code thinking of the future. This instilled many 
skills I didn’t think about till much later, such DRY techniques and so on.

 I left CSS for my next job and quickly realized that not all programming shops
 have developed programming tools, programming standards or even standard
 screen formatting. In this job I started to recreate many of the tools I had
 used or written while working at CSS.

 At this point I was still not thinking of portability. I thought I would just 
 develop these tools for that job. During this period, I picked up a contract
 side job and realized I wanted to bring all my tools over there. My program
 development manager at the time got me the side job, so he was ok with me 
 porting many of the tools to the new company.

 After leaving that job and starting a new one, I realized that recreating
 this stuff again was not going to be easy. I decided to put the tools into
 a single package and make it open source so I could use it at any job I
 work at in the future.

 The following are some of the people that gave me ideas for the tools.

 **Bill and Mark McClendon** at CSS. These were my programming mentors and during
 my time working with them I developed many of the skills and tools that I 
 ended up recreating in this package.

 **Bryan Younger**, with the help of **Stacy Grady**. These were fellow 
 programmers at my second job. They came up with the 3 character shortcut codes 
 used to assist in development. I'm not sure if they got them from somewhere 
 else or not, but once you start using them it's hard to not have them.

 **Scott Kelement** everyone’s favorite RPG programmer they never pay. Some of
 his open-source projects have been integrated into this package. 

 **Gary West** was the inspiration for the entire dictionary system. It was  
 built using tactics he developed at a previous jobs. This system grew into
 the file master system and the program master system. Even though I didn't meet
 Gary till years after I left CSS, he originally started CSS, partnering with 
 Bill McClendon. It was kind of interesting seeing how his new development
 paralleled some of the development I did at CSS.
