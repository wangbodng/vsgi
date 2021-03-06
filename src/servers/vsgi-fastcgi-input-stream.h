/*
 * This file is part of Valum.
 *
 * Valum is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Valum is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Valum.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __VSGI_FASTCGI_INPUT_STREAM_H__
#define __VSGI_FASTCGI_INPUT_STREAM_H__

#include <gio/gio.h>
#include <gio/gunixinputstream.h>

#include <fcgiapp.h>

G_BEGIN_DECLS

#define VSGI_FASTCGI_TYPE_INPUT_STREAM (vsgi_fastcgi_input_stream_get_type ())
GType vsgi_fastcgi_input_stream_get_type (void);

typedef struct _VSGIFastCGIInputStream VSGIFastCGIInputStream;

typedef struct {
    GUnixInputStreamClass parent_class;
} VSGIFastCGIInputStreamClass;

#define VSGI_FASTCGI_INPUT_STREAM(ptr) G_TYPE_CHECK_INSTANCE_CAST (ptr, vsgi_fastcgi_input_stream_get_type (), VSGIFastCGIInputStream)
#define VSGI_FASTCGI_IS_INPUT_STREAM(ptr) G_TYPE_CHECK_INSTANCE_TYPE (ptr, vsgi_fastcgi_input_stream_get_type ())

VSGIFastCGIInputStream * vsgi_fastcgi_input_stream_new (gint fd, FCGX_Stream *in);

G_END_DECLS

#endif
