<%include file="/support/header.mako" args="environ=environ, title='Settings'"/>\
<%namespace module="toolserver.settings" import="main"/>\
<% bot, cookies, langs, projects = main(environ, headers) %>
            <h1>Settings</h1>
            <p>This page contains some configurable options for this Toolserver site. Settings are saved as cookies. You can view and delete all cookies generated by this site at the bottom of this page.</p>
            <form action="${environ['PATH_INFO']}" method="post">
                <input type="hidden" name="action" value="set">
                <table>
                    <tr>
                        <td>Default site:</td>
                        <td>
                            <tt>http://</tt>
                            <select name="lang">
                                <% selected_lang = cookies["EarwigDefaultLang"].value if "EarwigDefaultLang" in cookies else bot.wiki.get_site().lang %>
                                % for code, name in langs:
                                    % if code == selected_lang:
                                        <option value="${code}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <tt>.</tt>
                            <select name="project">
                                <% selected_project = cookies["EarwigDefaultProject"].value if "EarwigDefaultProject" in cookies else bot.wiki.get_site().project %>
                                % for code, name in projects:
                                    % if code == selected_project:
                                        <option value="${code}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <tt>.org</tt>
                        </td>
                    </tr>
                    <tr>
                        <td>Background:</td>
                    </tr>
                    <tr>
                        <td><button type="submit">Save</button></td>
                    </tr>
                </table>
            </form>
            <h2>Cookies</h2>
            % if cookies:
                <table>
                % for cookie in cookies.itervalues():
                    <tr>
                        <td><b><tt>${cookie.key | h}</tt></b></td>
                        <td><tt>${cookie.value | h}</tt></td>
                        <td>
                            <form action="${environ['PATH_INFO']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="cookie" value="${cookie.key | h}">
                                <button type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                % endfor
                    <tr>
                        <td>
                            <form action="${environ['PATH_INFO']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="all" value="1">
                                <button type="submit">Delete all</button>
                            </form>
                        </td>
                    </tr>
                </table>
            % else:
                <p>No cookies!</p>
            % endif
<%include file="/support/footer.mako" args="environ=environ"/>
