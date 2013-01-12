from rest_framework import permissions


class ReadOnly(permissions.BasePermission):

    def has_permission(self, request, view, obj=None):
        return request.method in permissions.SAFE_METHODS
