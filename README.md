# Media Ranker Revisited

## Learning Goals
- Add tests to controllers to verify controller logic
- Practice using OAuth in a web application
- Practice using Session variables to track a user across multiple HTTP requests

## Project Description

We are providing you with an implementation of MediaRanker. Use this MediaRanker to begin this project.

Our MediaRanker web app was a wonderful website with two major flaws:
1. our controllers are untested
1. the way we implemented user login is extremely insecure

In this assignment you will modify Media Ranker in two ways:
1. our controllers will finally have tests that test controller logic
1. our web app can securely **authenticate** multiple users via OAuth and **authorize** them to view, manage and vote on works

Build your project using _branches_, with at least _one branch_ per wave.  As you finish a wave merge the changes into the main branch. Submit one pull request at the end once you are complete.

## Wave 1: Controller Tests

Take some time to understand what each controller is doing. Add tests to the existing controllers in this project. Be sure to consider both nominal and edge cases for every user flow possible.

### Requirements
- Tests on CRUD operations that your controller can execute
  - Create
    - What should happen if the controller executes creation of something with valid data?
    - ... with invalid data?
  - Read (Show)
    - What should happen if the controller tries to read/show an ID of a model that exists in the DB?
    - ... that doesn't exist in the DB?
  - Update
    - What should happen if the controller executes an update of something with valid data?
    - ... with invalid data?
  - Delete
    - What should happen if the controller tries to delete an ID of a model that exists in the DB?
    - ... that doesn't exist in the DB?
- Tests rendering, routing, and HTTP status when appropriate
- Tests updates to the model when appropriate
- Tests custom controller logic and custom routes when appropriate
  - Tests positive, negative, nominal and edge cases

## Wave 2: Authentication via OAuth

Following the steps in the Textbook curriculum, add OAuth to your Media Ranker Application and enable a user to log in.

### Requirements
- Add all necessary gems and configuration
- Repurpose the existing login functionality to now be a single log in button (on home page or nav bar)
- The log in button shall turn in to a log out button when the user is logged in
- All other requirements from in-class notes apply:
  - Managed via `session`
  - `SessionsController`
  - `User` model 

## Wave 3: Basic Authorization (Page Access)

In this wave we will create authorization logic to enforce rules that govern what pages on the site users and guests (unauthenticated browsers) can view. The rule we'll use is that guests can only access the main page, and all logged-in users can access the show and index pages for all categories of work.

### Requirements
-  Ensure that users who are not logged in can see *only* the main page with the spotlight and top 10 items. No other pages should be viewable by the guest user.
-  Ensure that users who are logged in can see the rest of the pages.
- Full unit testing around authentication using mocks


## Optional Wave 4: Advanced Authorization (Ownership)

Create advanced authorization logic to enforce rules that govern what _changes_ users can make to the site's data. The rules here are more complex than for accessing pages:
- Guests cannot change any data on the site
- All logged-in users can add new works to the site
  - Those works are owned by the user that created them
- The user who owns a given work can:
  - Edit that work
  - Delete that work

### Tasks
- Modify the edit and delete functionality to ensure that users can only change works they are associated with.
  - Consider how this could be implemented at the model layer.
- Do some research into how to use Google or another OAuth provider for authentication and use that provider.

## Due Date
This project is due before class Tuesday October 30 via PR against Ada-C10/MediaRanker-Revisited.

## Resources
- [Ada Textbook Curriculum: Controller Testing](https://github.com/Ada-Developers-Academy/textbook-curriculum/blob/master/08-rails/test-controllers.md)
-  [Ada Textbook Curriculum: Session](https://github.com/Ada-Developers-Academy/textbook-curriculum/blob/master/09-intermediate-rails/session.md)
- [Ada Textbook Curriculum: OAuth](https://github.com/Ada-Developers-Academy/textbook-curriculum/blob/master/09-intermediate-rails/oauth.md)
-  [OmniAuth Gem](https://github.com/omniauth/omniauth)
- [Ada Textbook Curriculum: Testing Authentication Using Mocks](https://github.com/Ada-Developers-Academy/textbook-curriculum/blob/master/09-intermediate-rails/testing-auth.md)
