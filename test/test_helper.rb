def __DIR__; File.dirname(__FILE__); end

$:.unshift(__DIR__ + '/../lib')
$:.unshift(__DIR__ + '/../../../rails/activesupport/lib')

require 'test/unit'
require 'active_support'
require 'cgi'
require 'nkf'


