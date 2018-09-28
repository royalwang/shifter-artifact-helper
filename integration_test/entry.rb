require 'test/unit'
require 'open-uri'
require 'openssl'
require 'json'

# Usage: https://qiita.com/repeatedly/items/727b08599d87af7fa671
# Assertions: https://test-unit.github.io/test-unit/ja/Test/Unit/Assertions.html

REMOTE_SERVER='https://127.0.0.1:8443'

def get_urls(path:, urls: 0, max: 100)
  res = open(
    "https://127.0.0.1:8443#{path}?urls=#{urls}&max=#{max}",
    :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  ).read
  return JSON.load(res)
end

def count_by(items, type, value)
  result = items['items'].select { |i| i[type] == value }
  return result.size
end


class TestRootPath < Test::Unit::TestCase
  description '/?urls=0&max=100'
  items = get_urls(path: '/')

  data(
    'all_counts' => [items['count'], 100],
    'start' => [items['start'], 0],
    'end' => [items['end'], 100],
    'finished' => [items['finished'], false],
    'home' => [count_by(items, 'link_type', 'home'), 1],
    '404' => [count_by(items, 'link_type', '404'), 1],
    'feed' => [count_by(items, 'link_type', 'feed'), 5],
    'permalink' => [count_by(items, 'link_type', 'permalink'), 52],
    'amphtml' => [count_by(items, 'link_type', 'amphtml'), 38],
  )

  def test_root_path_first(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  description '/?urls=4&max=100'
  items = get_urls(path: '/', urls: 4)

  data(
    'all_counts' => [items['count'], 23],
    'start' => [items['start'], 400],
    'end' => [items['end'], 500],
    'finished' => [items['finished'], true],
  )

  def test_root_path_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestRedirectLimit < Test::Unit::TestCase
  # Limit case: redirection only items
  description '/?urls=41&max=10'
  items = get_urls(path: '/', urls: 41, max: 10)

  data(
    'all_counts' => [items['count'], 10],
    'finished' => [items['finished'], false],
    'redirection' => [count_by(items, 'link_type', 'redirection'), 10],
  )

  def test_redirection_counts_pre_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # Limit case: redirection only items
  description '/?urls=42&max=10'
  items = get_urls(path: '/', urls: 42, max: 10)

  data(
    'all_counts' => [items['count'], 3],
    'finished' => [items['finished'], true],
    'redirection' => [count_by(items, 'link_type', 'redirection'), 3],
  )

  def test_redirection_counts_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestCategoryPagenates < Test::Unit::TestCase
  description 'Category pagenation'
  items = get_urls(path: '/category/markup/')

  data(
    'all_counts' => [items['count'], 2],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 2],
  )

  def test_category_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestArchivePagenates < Test::Unit::TestCase
  description 'Archive pagenation'
  items = get_urls(path: '/2010/')

  data(
    'all_counts' => [items['count'], 7],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 7],
  )

  def test_archive_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestPostHasNextPage < Test::Unit::TestCase
  description 'has Nextpage'
  items = get_urls(path: '/2012/01/template-paginated/')

  data(
    'all_counts' => [items['count'], 2],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 2],
  )

  def test_nexpage_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end