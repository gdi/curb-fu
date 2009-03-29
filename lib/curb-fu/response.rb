module CurbFu
  module Response
    class Base
      attr_accessor :status, :body
      
      def initialize(curb)
        @status = curb.response_code
        @body = curb.body_str
      end
      
      def self.create(curb)
        response = self.new(curb)

        case response.status
        when 100..199 then
          response.extend CurbFu::Response::Information
          case response.status
          when 101 then response.extend CurbFu::Response::Continue
          when 102 then response.extend CurbFu::Response::SwitchProtocl
          end
        when 200..299 then
          response.extend CurbFu::Response::Success
          case response.status
          when 200 then response.extend CurbFu::Response::OK
          when 201 then response.extend CurbFu::Response::Created
          when 202 then response.extend CurbFu::Response::Accepted
          when 203 then response.extend CurbFu::Response::NonAuthoritativeInformation
          when 204 then response.extend CurbFu::Response::NoContent
          when 205 then response.extend CurbFu::Response::ResetContent
          when 206 then response.extend CurbFu::Response::PartialContent
          end
        when 300..399 then
          response.extend CurbFu::Response::Redirection
          case response.status
          when 300 then response.extend CurbFu::Response::MultipleChoice
          when 301 then response.extend CurbFu::Response::MovedPermanently
          when 302 then response.extend CurbFu::Response::Found
          when 303 then response.extend CurbFu::Response::SeeOther
          when 304 then response.extend CurbFu::Response::NotModified
          when 305 then response.extend CurbFu::Response::UseProxy
          when 307 then response.extend CurbFu::Response::TemporaryRedirect
          end
        when 400..499 then
          response.extend CurbFu::Response::ClientError
          case response.status
          when 400 then response.extend CurbFu::Response::BadRequest
          when 401 then response.extend CurbFu::Response::Unauthorized
          when 402 then response.extend CurbFu::Response::PaymentRequired
          when 403 then response.extend CurbFu::Response::Forbidden
          when 404 then response.extend CurbFu::Response::NotFound
          when 405 then response.extend CurbFu::Response::MethodNotAllowed
          when 406 then response.extend CurbFu::Response::NotAcceptable
          when 407 then response.extend CurbFu::Response::ProxyAuthenticationRequired
          when 408 then response.extend CurbFu::Response::RequestTimeOut
          when 409 then response.extend CurbFu::Response::Conflict
          when 410 then response.extend CurbFu::Response::Gone
          when 411 then response.extend CurbFu::Response::LengthRequired
          when 412 then response.extend CurbFu::Response::PreconditionFailed
          when 413 then response.extend CurbFu::Response::RequestEntityTooLarge
          when 414 then response.extend CurbFu::Response::RequestURITooLong
          when 415 then response.extend CurbFu::Response::UnsupportedMediaType
          when 416 then response.extend CurbFu::Response::UnsupportedMediaType
          when 417 then response.extend CurbFu::Response::ExpectationFailed
          end
        when 500..599 then
          response.extend CurbFu::Response::ServerError
          case response.status
          when 500 then response.extend CurbFu::Response::InternalServerError
          when 501 then response.extend CurbFu::Response::NotImplemented
          when 502 then response.extend CurbFu::Response::BadGateway
          when 503 then response.extend CurbFu::Response::ServiceUnavailable
          when 504 then response.extend CurbFu::Response::GatewayTimeOut
          when 505 then response.extend CurbFu::Response::VersionNotSupported
          end
        else
          response.extend CurbFu::Response::UnknownResponse
        end
        
        response
      end
    end
          
    module Information; end
      module Continue; end
      module SwitchProtocl; end
      module Success; end
      module OK; end
      module Created; end
      module Accepted; end
      module NonAuthoritativeInformation; end
      module NoContent; end
      module ResetContent; end
      module PartialContent; end
    module Redirection; end                    # 3xx
      module MultipleChoice; end                 # 300
      module MovedPermanently; end               # 301
      module Found; end                          # 302
      module SeeOther; end                       # 303
      module NotModified; end                    # 304
      module UseProxy; end                       # 305
      module TemporaryRedirect; end              # 307
    module ClientError; end                    # 4xx
      module BadRequest; end                     # 400
      module Unauthorized; end                   # 401
      module PaymentRequired; end                # 402
      module Forbidden; end                      # 403
      module NotFound; end                       # 404
      module MethodNotAllowed; end               # 405
      module NotAcceptable; end                  # 406
      module ProxyAuthenticationRequired; end    # 407
      module RequestTimeOut; end                 # 408
      module Conflict; end                       # 409
      module Gone; end                           # 410
      module LengthRequired; end                 # 411
      module PreconditionFailed; end             # 412
      module RequestEntityTooLarge; end          # 413
      module RequestURITooLong; end              # 414
      module UnsupportedMediaType; end           # 415
      module RequestedRangeNotSatisfiable; end   # 416
      module ExpectationFailed; end              # 417
    module ServerError; end                    # 5xx
      module InternalServerError; end            # 500
      module NotImplemented; end                 # 501
      module BadGateway; end                     # 502
      module ServiceUnavailable; end             # 503
      module GatewayTimeOut; end                 # 504
      module VersionNotSupported; end            # 505
    module UnknownResponse; end
  end
end