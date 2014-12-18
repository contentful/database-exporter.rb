require 'spec_helper'
require './lib/migrator'
require './spec/support/db_rows_json.rb'

describe Migrator do

  before do
    @setting_file = YAML.load_file('spec/fixtures/settings/settings.yml')
  end

  it 'Fetching data from DB and mapping process' do
    FileUtils.rm_rf('spec/fixtures/database/data')

    # Extract data from database
    Migrator.new(@setting_file).run('--extract-to-json')

    expect(Dir.glob('spec/fixtures/database/data/entries/*').count).to eq 5
    expect(Dir.glob('spec/fixtures/database/data/**/*').count).to eq 34

    directory_names = %w(comment job_skills jobs profile user)
    Dir.glob('spec/fixtures/database/data/entries/*') do |directory_name|
      expect(directory_names.include?(File.basename(directory_name))).to be true
    end

    expect(load_fixture('database/data/entries/comment/comment_1')).to include(id: 'comment_1', subject: 'Title comment 1', content: 'Body comment 1', job_add_id: 1, database_id: 1)
    expect(load_fixture('database/data/entries/job_skills/job_skills_1')).to include(id: 'job_skills_1', name: 'Commercial awareness', database_id: 1)
    expect(load_fixture('database/data/entries/jobs/jobs_4')).to include(id: 'jobs_4', name: 'Awesome job', specification: 'One word - awesome!', image_id: 2, user_id: 2, database_id: 4)
    expect(load_fixture('database/data/entries/profile/profile_1')).to include(id: 'profile_1', nickname: 'Nickname 1', user_id: 1)
    expect(load_fixture('database/data/entries/user/user_1')).to include(id: 'user_1', first_name: 'FirstName', last_name: 'LastName', birthday: '2009-04-16T09:43:00+00:00', database_id: 1)

    # Mapping
    Migrator.new(@setting_file).run('--prepare-json')

    expect(Dir.glob('spec/fixtures/database/data/**/*').count).to eq 39

    user = load_fixture('database/data/entries/user/user_1')
    expect(user['profile']).to be_a Hash
    expect(user['profile']).to include(type: 'profile', id: 'profile_1')
    expect(user['job_adds'].count).to eq 2
    expect(user['job_adds']).to be_a Array
    expect(user['job_adds'].first).to include(type: 'jobs', id: 'jobs_1')

    profile = load_fixture('database/data/entries/profile/profile_1')
    expect(profile['user']).to be_a Hash
    expect(profile['user']).to include(type: 'Entry', id: 'user_1')

    job = load_fixture('database/data/entries/jobs/jobs_1')
    expect(job).to include first_name: 'FirstName'
    expect(job['image']).to be_a Hash
    expect(job['image']).to include(type: 'File', id: 'image_3')
    expect(job['creator']).to be_a Hash
    expect(job['creator']).to include(type: 'Entry', id: 'user_1')
    expect(job['comments'].count).to eq 3
    expect(job['comments']).to be_a Array
    expect(job['comments'].first).to include(type: 'comment', id: 'comment_1')
    expect(job['skills']).to be_a Array
    expect(job['skills'].first).to include(type: 'job_skills', id: 'job_skills_1')
    expect(job['subjects_comments']).to be_a Array
    expect(job['subjects_comments']).to include('Title comment 1', 'Title comment 2', 'Title comment 3')
  end

  it 'list tables' do
    Migrator.new(@setting_file).run('--list-tables')
    tables = load_json('database/data/table_names')
    expect(tables).to be_a Array
    expect(tables.count).to eq 8
    expect(tables).to include('schema_migrations', 'skills', 'job_adds', 'comments', 'images', 'job_add_skills', 'users', 'profiles')
  end

  it 'convert contentful model to contentful structure' do
    Migrator.new(@setting_file).run('--convert-content-model-to-json')
    contentful_structure = load_fixture('settings/contentful_structure_test')
    expect(contentful_structure.count).to eq 5
    expect(contentful_structure['Jobs']).to include(id: '4L1bg4WQ5aWQMiE82ouag', name: 'Jobs', displayField: 'title', description: nil)
    expect(contentful_structure['Jobs']['fields'].count).to eq 5
    expect(contentful_structure['Jobs']['fields']['Image']).to include(id: 'image', type: 'Asset', link: 'Link')
    expect(contentful_structure['Jobs']['fields']['Creator']).to include(id: 'creator', type: 'Entry', link: 'Link')
    expect(contentful_structure['Jobs']['fields']['Comments']).to include(id: 'comments', type: 'Array', link_type: 'Entry', link: 'Link')
  end

  it 'create content type json files from contentful structure' do
    Migrator.new(@setting_file).run('--create-content-model-from-json')
    expect(Dir.glob('spec/fixtures/database/data/collections/*').count).to eq 5
    content_types_files = %w(comment.json job_skills.json jobs.json profile.json user.json)
    Dir.glob('spec/fixtures/database/data/collections/*') do |directory_name|
      expect(content_types_files.include?(File.basename(directory_name))).to be true
    end
    comment = load_fixture('database/data/collections/comment')
    expect(comment).to include(id: '6H6pGAV1PUsuoAW26Iu48W', name: 'Comment', displayField: 'subject')
    expect(comment['fields'].count).to eq 2
    expect(comment['fields'].first).to include(id: 'subject', name: 'Subject', type: 'Text')

    job_skills = load_fixture('database/data/collections/job_skills')
    expect(job_skills).to include(id: '2soCP557HGKoOOK0SqmMOm', name: 'Job Skills', displayField: 'name')
    expect(job_skills['fields'].count).to eq 1
    expect(job_skills['fields'].first).to include(id: 'name', name: 'Name', type: 'Text')

    jobs = load_fixture('database/data/collections/jobs')
    expect(jobs).to include(id: '4L1bg4WQ5aWQMiE82ouag', name: 'Jobs', displayField: 'title')
    expect(jobs['fields'].count).to eq 6
    expect(jobs['fields'].last).to include(id: 'skills', name: 'Skills', type: 'Array', link_type: 'Entry', link: 'Link')

    profile = load_fixture('database/data/collections/profile')
    expect(profile).to include(id: '4WFZh4MwC4Mc0EQWAeOY8A', name: 'Profile', displayField: nil)
    expect(profile['fields'].count).to eq 2
    expect(profile['fields'].first).to include(id: 'nickname', name: 'Nickname', type: 'Text')

    user = load_fixture('database/data/collections/user')
    expect(user).to include(id: '1TVvxCqoRq0qUYAOQuOqys', name: 'User', displayField: 'first_name')
    expect(user['fields'].first).to include(id: 'first_name', name: 'First_name', type: 'Text')
  end

end
