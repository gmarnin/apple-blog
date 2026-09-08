---
title: Creating Managed Apple Accounts Accounts
parent: Docs
nav_order: 1
---


## Creating Managed Apple Accounts Accounts

Updated 9-8-2026 | Draft Version 1.3.0 | Marnin Goldberg, OIT EDM

> The ASM URL is [https://school.apple.com](https://school.apple.com) - Safari or Chrome recommended
> 
> The official [Apple School Manager User Guide](https://support.apple.com/en-ca/guide/apple-school-manager/welcome/web)

You need to have a role of People Manager or higher in ASM for these workflows

### Managed Apple Accounts

Apple Accounts is the new name for Apple IDs. Perhaps Apple didn't like that Managed Apple Accounts were known as MAIDs? 

Managed Apple Accounts are primarily used by IT staff to log in to Apple School Manager (ASM) and [Apple Seed for IT](https://beta.apple.com/for-it). There are other use cases for Managed Apple Accounts, such as departments that want to use iCloud but want more management over it. Less popular use cases include shared iPads, Apple User Enrollments, and Volume Purchase Program (VPP) accounts. 

Know the use case for Managed Apple Account before making one. 

> We need a Rutgers based email address (or alias address) that hasn’t previously been associated with an Apple Account. Don't allow use of a generic account for accountability reasons. 

#### Directions for Creating a New Managed Apple Account

Log in to ASM

Select `Users` from the menu on the left side

Select the `+ Add` button to the right of the search bar

On the `Add New User` form, fill out the following fields: 

* First Name
* Last Name
* Managed Apple Account and the Rutgers domain from the drop down
* Email Address - usually use the UPN address

For accounts that need ASM access (generally IT folks):
* Choose a Role - Device Enrollment Manager 
* Choose a Location - Rutgers University
* Add a second role if the user needs access to VPP Apps and Books. The role for that would be Content Manager, and the Location should match the user's department 

For general use accounts that don't need ASM access:
* Choose a Role - Staff
* Choose a Location - Rutgers University

> New Locations can be set up if needed. Select Locations from the menu on the left side

All other fields are optional

Select `Save` at the bottom of the form

On the next screen, select `Create Sign-In` from the top menu 

Select `Send as an email`

Inform the user to check the email used for the Managed Apple Account. The from address is `Apple School Manager <no-reply@apple.com>` 

The email contains a link to ASM and a temporary password. The user will be forced to reset their password. The new password must meet the following requirements: 

* At least 8 characters
* At least 1 number
* At least 1 uppercase letter
* At least 1 lowercase letter
* At least one special character

After authenticating with the temporary password, the user will be required to add a trusted phone number for 2FA. 



### Resetting a Managed Apple Account Password

Managed Apple Accounts in ASM have passwords that are not in sync or tied to any directory service. The password is created by the end user when the account is created. 

A Managed Apple Account password can only be reset in ASM. You can not see the user's password in ASM. 

#### Password Reset Directions

Log in to ASM

Select `Users` from the menu on the left side

Search for the user name and select it

Select `Reset Password` 

Select `Send as an email` and check off `Sign out of Apple devices and websites associated with this Apple Account`

> The password reset details in the email will expire in 90 days

Select `Continue`

Inform the user to check the email used for the Managed Apple Account. The from address is `Apple School Manager <no-reply@apple.com>` 

The email contains a link to ASM and a temporary password. The user will be forced to reset their password. The new password must meet the following requirements: 

* At least 8 characters
* At least 1 number
* At least 1 uppercase letter
* At least 1 lowercase letter
* At least one special character

### Resetting a Managed Apple Account 2FA Phone Number

A phone number is required for 2FA. We can reset the number associated with the Managed Apple Account in ASM

Log in to ASM

Select `Users` from the menu on the left side

Search for the user name and select it

Select `Reset Password` from the top menu

Select `Reset` 

When the user signs in again, they’re prompted to add a new phone number
