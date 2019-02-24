# frozen_string_literal: true

module FindCircleYml
  module GitHub
    class Service
      attr_reader :user, :access_token, :organization

      def initialize(user, access_token, organization)
        @user = user
        @access_token = access_token
        @organization = organization
      end

      def repositories
        fetch_repos.map do |response|
          Repository.new(
            response[:full_name],
            response[:default_branch],
            response[:html_url]
          )
        end
      end

      def configuration_file(repository)
        ConfigurationFile.new(
          client.contents(repository.name, path: 'circle.yml')[:html_url]
        )
      rescue Octokit::NotFound
        nil
      end

      private

      def client
        Octokit.auto_paginate = true
        Octokit::Client.new(login: user, password: access_token)
      end

      def fetch_repos
        organization ? client.organization_repositories(organization) : client.repositories
      end
    end
  end
end
