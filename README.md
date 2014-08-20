
# Workflowable

## What is Workflowable?

Workflowable is a Ruby gem that allows adding flexible workflow functionality to Ruby on Rails Applications. Workflowable provides an admin interface for configuring workflows, adding stages, triggering automatic actions, etc.

An example of an application using Workflowable is [Scumblr](https://www.github.com/Netlfix/Scumblr)

## How do I use Workflowable?

Workflowable is installed as a gem as part of a Ruby on Rails web application. In order to use workflowable you'll need to:

1. Install/setup the gem
2. Run the database migrations
3. Add "acts_as_workflowable" to one more model you want associated with workflow
4. Setup your workflow
5. Optionally create automated actions that occur during certain states (notifications, ticket creation, external API calls, etc.)

# Sounds great! How do I get started?

Take a look at the [wiki](https://www.github.com/Netflix/Workflowable/wiki) for detailed instructions on setup, configuration, and use!

