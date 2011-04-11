module CurbFu
  module Response
    class Base
      attr_accessor :status, :body, :headers
      
      def initialize(status, headers, body)
        @status = status
        set_response_type(status)
        @body = body
        @headers = headers.is_a?(String) ? parse_headers(headers) : headers
      end
      
      def success?
        self.is_a?(CurbFu::Response::Success)
      end
      
      def redirect?
        self.is_a?(CurbFu::Response::Redirection)
      end
      
      def failure?
        !(success? || redirect?)
      end
      
      def server_fail?
        self.is_a?(CurbFu::Response::ServerError)
      end
      
      def client_fail?
        self.is_a?(CurbFu::Response::ClientError)
      end
      
      def parse_headers(header_string)
        header_lines = header_string.split($/)
        header_lines.shift
        header_lines.inject({}) do |hsh, line|
          whole_enchillada, key, value = /^(.*?):\s*(.*)$/.match(line.chomp).to_a
          unless whole_enchillada.nil?
            # note: headers with multiple instances should have multiple values in the headers hash
            hsh[key] = hsh[key] ? hsh[key].to_a << value : value
          end
          hsh
        end
      end
      
      def to_hash
        { :status => status, :body => body, :headers => headers }
      end

      def content_length
        if ( header_value = get_fields('Content-Length').to_a.last )
          header_value.to_i
        end
      end

      def content_type
        if ( header_value = get_fields('Content-Type').to_a.last )
          header_value.split(';').first
        end
      end

      def get_fields(key)
        if ( match = @headers.find{|k,v| k.downcase == key.downcase} )
          [match.last].flatten
        else
          []
        end
      end

      def [](key)
        get_fields(key).last
      end

      def set_response_type(status)
        case status
        when 100..199 then
          self.extend CurbFu::Response::Information
          case self.status
          when 101 then self.extend CurbFu::Response::Continue
          when 102 then self.extend CurbFu::Response::SwitchProtocl
          end
        when 200..299 then
          self.extend CurbFu::Response::Success
          case self.status
          when 200 then self.extend CurbFu::Response::OK
          when 201 then self.extend CurbFu::Response::Created
          when 202 then self.extend CurbFu::Response::Accepted
          when 203 then self.extend CurbFu::Response::NonAuthoritativeInformation
          when 204 then self.extend CurbFu::Response::NoContent
          when 205 then self.extend CurbFu::Response::ResetContent
          when 206 then self.extend CurbFu::Response::PartialContent
          end
        when 300..399 then
          self.extend CurbFu::Response::Redirection
          case self.status
          when 300 then self.extend CurbFu::Response::MultipleChoice
          when 301 then self.extend CurbFu::Response::MovedPermanently
          when 302 then self.extend CurbFu::Response::Found
          when 303 then self.extend CurbFu::Response::SeeOther
          when 304 then self.extend CurbFu::Response::NotModified
          when 305 then self.extend CurbFu::Response::UseProxy
          when 307 then self.extend CurbFu::Response::TemporaryRedirect
          end
        when 400..499 then
          self.extend CurbFu::Response::ClientError
          case self.status
          when 400 then self.extend CurbFu::Response::BadRequest
          when 401 then self.extend CurbFu::Response::Unauthorized
          when 402 then self.extend CurbFu::Response::PaymentRequired
          when 403 then self.extend CurbFu::Response::Forbidden
          when 404 then self.extend CurbFu::Response::NotFound
          when 405 then self.extend CurbFu::Response::MethodNotAllowed
          when 406 then self.extend CurbFu::Response::NotAcceptable
          when 407 then self.extend CurbFu::Response::ProxyAuthenticationRequired
          when 408 then self.extend CurbFu::Response::RequestTimeOut
          when 409 then self.extend CurbFu::Response::Conflict
          when 410 then self.extend CurbFu::Response::Gone
          when 411 then self.extend CurbFu::Response::LengthRequired
          when 412 then self.extend CurbFu::Response::PreconditionFailed
          when 413 then self.extend CurbFu::Response::RequestEntityTooLarge
          when 414 then self.extend CurbFu::Response::RequestURITooLong
          when 415 then self.extend CurbFu::Response::UnsupportedMediaType
          when 416 then self.extend CurbFu::Response::UnsupportedMediaType
          when 417 then self.extend CurbFu::Response::ExpectationFailed
          end
        when 500..599 then
          self.extend CurbFu::Response::ServerError
          case self.status
          when 500 then self.extend CurbFu::Response::InternalServerError
          when 501 then self.extend CurbFu::Response::NotImplemented
          when 502 then self.extend CurbFu::Response::BadGateway
          when 503 then self.extend CurbFu::Response::ServiceUnavailable
          when 504 then self.extend CurbFu::Response::GatewayTimeOut
          when 505 then self.extend CurbFu::Response::VersionNotSupported
          end
        else
          self.extend CurbFu::Response::UnknownResponse
        end
      end
      
      class << self
        def from_rack_response(rack)
          raise ArgumentError.new("Rack response may not be nil") if rack.nil?
          response = self.new(rack.status, rack.headers, rack.body)
        end
      
        def from_curb_response(curb)
          response = self.new(curb.response_code, curb.header_str, curb.body_str)
          response
        end
        
        def from_hash(hash)
          return nil if hash.nil?
          self.new(hash[:status], hash[:headers], hash[:body])
        end
      end
    end
          
    module Information; end
      module Continue;                            def self.to_i; 100; end; def message; "Continue"; end; end
      module SwitchProtocol;                      def self.to_i; 101; end; def message; "Switch Protocol"; end; end
    module Success;                               def self.to_i; 200; end; def message; "Success"; end; end
      module OK;                                  def self.to_i; 200; end; def message; "OK"; end; end
      module Created;                             def self.to_i; 201; end; def message; "Created"; end; end
      module Accepted;                            def self.to_i; 202; end; def message; "Accepted"; end; end
      module NonAuthoritativeInformation;         def self.to_i; 203; end; def message; "Non Authoritative Information"; end; end
      module NoContent;                           def self.to_i; 204; end; def message; "No Content"; end; end
      module ResetContent;                        def self.to_i; 205; end; def message; "Reset Content"; end; end
      module PartialContent;                      def self.to_i; 206; end; def message; "Partial Content"; end; end
    module Redirection;                           def self.to_i; 300; end; def message; "Redirection"; end; end
      module MultipleChoice;                      def self.to_i; 300; end; def message; "Multiple Choice"; end; end
      module MovedPermanently;                    def self.to_i; 301; end; def message; "Moved Permanently"; end; end
      module Found;                               def self.to_i; 302; end; def message; "Found"; end; end
      module SeeOther;                            def self.to_i; 303; end; def message; "See Other"; end; end
      module NotModified;                         def self.to_i; 304; end; def message; "Not Modified"; end; end
      module UseProxy;                            def self.to_i; 305; end; def message; "Use Proxy"; end; end
      module TemporaryRedirect;                   def self.to_i; 307; end; def message; "Temporary Redirect"; end; end
    module ClientError;                           def self.to_i; 400; end; def message; "Client Error"; end; end
      module BadRequest;                          def self.to_i; 400; end; def message; "Bad Request"; end; end
      module Unauthorized;                        def self.to_i; 401; end; def message; "Unauthorized"; end; end
      module PaymentRequired;                     def self.to_i; 402; end; def message; "Payment Required"; end; end
      module Forbidden;                           def self.to_i; 403; end; def message; "Forbidden"; end; end
      module NotFound;                            def self.to_i; 404; end; def message; "Not Found"; end; end
      module MethodNotAllowed;                    def self.to_i; 405; end; def message; "Method Not Allowed"; end; end
      module NotAcceptable;                       def self.to_i; 406; end; def message; "Not Acceptable"; end; end
      module ProxyAuthenticationRequired;         def self.to_i; 407; end; def message; "Proxy Authentication Required"; end; end
      module RequestTimeOut;                      def self.to_i; 408; end; def message; "Request Time Out"; end; end
      module Conflict;                            def self.to_i; 409; end; def message; "Conflict"; end; end
      module Gone;                                def self.to_i; 410; end; def message; "Gone"; end; end
      module LengthRequired;                      def self.to_i; 411; end; def message; "Length Required"; end; end
      module PreconditionFailed;                  def self.to_i; 412; end; def message; "Precondition Failed"; end; end
      module RequestEntityTooLarge;               def self.to_i; 413; end; def message; "Request Entity Too Large"; end; end
      module RequestURITooLong;                   def self.to_i; 414; end; def message; "Request URI Too Long"; end; end
      module UnsupportedMediaType;                def self.to_i; 415; end; def message; "Unsupported Media Type"; end; end
      module RequestedRangeNotSatisfiable;        def self.to_i; 416; end; def message; "Requested Range Not Satisfiable"; end; end
      module ExpectationFailed;                   def self.to_i; 417; end; def message; "Expectation Failed"; end; end
    module ServerError;                           def self.to_i; 500; end; def message; "Server Error"; end; end
      module InternalServerError;                 def self.to_i; 500; end; def message; "Internal Server Error"; end; end
      module NotImplemented;                      def self.to_i; 501; end; def message; "Not Implemented"; end; end
      module BadGateway;                          def self.to_i; 502; end; def message; "Bad Gateway"; end; end
      module ServiceUnavailable;                  def self.to_i; 503; end; def message; "Service Unavailable"; end; end
      module GatewayTimeOut;                      def self.to_i; 504; end; def message; "Gateway Time Out"; end; end
      module VersionNotSupported;                 def self.to_i; 505; end; def message; "Version Not Supported"; end; end
    module UnknownResponse;                       def self.to_i; 0; end; def message; "Unknown Response"; end; end
  end
end
